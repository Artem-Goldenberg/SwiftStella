@preconcurrency import SwiftParsec

extension Program: StaticParsable {
    public static let parser: Parser<Program> = rule {
        lexer.whiteSpace // needed only at top level parser
        LanguageDeclaration.self
        LanguageExtension.parser.many
        Declaration.parser.many
    }.map(Self.init) <?> "stella program"
}

extension LanguageDeclaration: StaticParsable {
    public static let parser: Parser<Self> = rule {
        Keyword.language
        Keyword.core
        Sign.semicolon
        // static result
        Parser(result: Self.languageCore)
    } <?> "language declaration"
}

extension LanguageExtension: StaticParsable {
    public static let parser: Parser<Self> = rule {
        Keyword.extend
        Keyword.with
        LanguageExtension.Name.parser
            .commaSeparated
            .map(Self.init(names:))
        Sign.semicolon
    } <?> "extension declaration"
}

extension LanguageExtension.Name: StaticParsable {
    public static let parser: Parser<Self> = rule {
        Char.hash.parser.discard // don't propagate # to extension names
        CharGroup.alphaNum.with("-", "_").parser.many1
    }
        .lexeme // got to account for leading whitspaces as we are parsing raw chars
        .map { String($0) }
        .map(Self.init(value:)) <?> "extension name"
}

extension Identifier: StaticParsable {
    public static let parser: Parser<Self> = lexer.identifier.map(Self.init(value:))
}

extension MemoryAddress: StaticParsable {
    public static let parser: Parser<Self> = rule {
        Sign.hexStart
        CharGroup.hexDigit.parser.many1
    }.inAngles.map { Self.init(value: String($0)) } <?> "memory address"
}

extension Declaration: StaticParsable {
    public static let parser: Parser<Self> = alternatives {
        Keyword.exception.parser.flatMap { () in // if starts with an `exception` word
            // equivalte to `alternatives` function, just shorter here
            exceptionType <|> exceptionVariant
        }
        typeAlias // starts with a `type` keyword
        // functions: first parse annotations, then pass them to functions
        Annotation.parser.many.flatMap { annotations in
            alternatives {
                genericFunction(with: annotations)
                normalFunction(with: annotations)
            }
        }
    } <?> "declaration"

    // TODO: this functions are very similar, can we unite them?

    static func normalFunction(with annotations: [Annotation]) -> Parser<Self> {
        rule {
            Keyword.fn
            Identifier.parser <?> "function name"
            parameters
            returnType
            throwTypes
            functionBody
        }.map { (name, parameters, returnType, throwTypes, body) in
            let (declarations, returnExpression) = body
            return Self.function(
                annotations: annotations,
                name: name,
                parameters: parameters,
                returnType: returnType,
                throwTypes: throwTypes,
                body: declarations,
                return: returnExpression
            )
        } <?> "function"
    }

    static func genericFunction(with annotations: [Annotation]) -> Parser<Self> {
        rule {
            Keyword.generic
            Keyword.fn
            Identifier.parser <?> "function name"
            Identifier.parser
                .labels("type variable")
                .commaSeparated
                .inBrackets <?> "type variables"
            parameters
            returnType
            throwTypes
            functionBody
        }.map { (name, typeParameters, parameters, returnType, throwTypes, body) in
            let (declarations, returnExpression) = body
            return Self.genericFunction(
                annotations: annotations,
                name: name,
                typeVariables: typeParameters,
                parameters: parameters,
                returnType: returnType,
                throwTypes: throwTypes,
                body: declarations,
                return: returnExpression
            )
        } <?> "generic function"
    }

    static let parameters: Parser<[Parameter]> =
        Parameter
            .parser
            .commaSeparated
            .inParens <?> "parameters"

    static let functionBody: Parser<([Declaration], Expression)> = rule {
        rule {
            Declaration.self
            Sign.semicolon.parser.optional
        }.many
        Keyword.return
        Stella.Expression.self
    }.inBraces <?> "function body"

    static let returnType: Parser<Type?> = rule {
        Sign.arrow
        Type.self
    }.optional <?> "return type"

    static let throwTypes: Parser<[Type]> = rule {
        Keyword.throws
        Type.parser.commaSeparated1
    }.optional.map { $0 ?? [] } <?> "throw type" // if no `throws` return []

    static let typeAlias: Parser<Self> = rule {
        Keyword.type
        Identifier.self
        Sign.equals
        Type.self
    }.map(Self.typeAlias) <?> "typealias"

    // `exception` already parsed
    static let exceptionType: Parser<Self> = rule {
        Keyword.type
        Sign.equals
        Type.parser
    }.map(Self.exceptionType) <?> "exception type"

    // `exception` already parsed
    static let exceptionVariant: Parser<Self> = rule {
        Keyword.variant
        Identifier.self
        Sign.colon
        Type.self
    }.map(Self.exceptionVariant) <?> "exception variant"
}

extension Declaration.Annotation {
    static let parser: Parser<Self> = rule {
        Keyword.inline // for now only inline keyword
        .map { Self.inline } <?> "inline"
    } <?> "annotation"
}

extension Declaration.Parameter: StaticParsable {
    public static let parser: Parser<Self> = rule {
        Identifier.self
        Sign.colon
        Type.self
    }.map(Self.init) <?> "parameter"
}
