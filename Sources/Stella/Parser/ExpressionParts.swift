@preconcurrency import SwiftParsec

extension Stella.Expression: StaticParsable {
    static func ifExpression(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.if
            thisParser
            Keyword.then
            thisParser
            Keyword.else
            thisParser
        }.map(Self.if) <?> "if condition"
    }

    static func letExpression(using thisParser: Parser<Self>, recursive: Bool) -> Parser<Self> {
        let keyword = recursive ? Keyword.letrec : Keyword.let
        return rule {
            keyword
            rule {
                Pattern.self
                Sign.equals
                thisParser
            }.commaSeparated1 <?> "pattern binding"
            Keyword.in
            thisParser
        }.map(recursive ? Self.letrec : Self.let) <?> "\(keyword) expression"
    }

    static func generic(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.generic
            Identifier.parser
                .commaSeparated
                .inBrackets
            thisParser
        }.map(Self.typeAbstraction) <?> "generic expression"
    }

    static func lambda(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.fn
            Declaration.parameters
            rule {
                Keyword.return
                thisParser
            }.inBraces
        }.map(Self.abstraction) <?> "lambda"
    }

    static func variant(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Identifier.self
            rule {
                Sign.equals
                thisParser
            }.optional <?> "expression data"
        }
        .inClips
        .map(Self.variant) <?> "variant experssion"
    }

    static func match(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.match
            thisParser
            rule {
                Pattern.self
                Sign.logicArrow
                thisParser
            }
            .labels("match case")
            .separatedBy(Sign.pipe.parser)
            .inBraces <?> "match clause"
        }
        .map(Self.match) <?> "match expression"
    }

    static func list(using thisParser: Parser<Self>) -> Parser<Self> {
        thisParser
            .commaSeparated
            .inBrackets
            .map(Self.list) <?> "list expresssion"
    }

    @ParserBuilder
    static func tryExpression(using thisParser: Parser<Self>) -> Parser<Self> {
        Keyword.try
        thisParser.inBraces.flatMap { tried in alternatives {
            rule {
                Keyword.catch
                rule {
                    Pattern.self
                    Sign.logicArrow
                    thisParser
                }.inBraces
            }.map { Self.tryCatch(tried, $0, $1) } <?> "try catch expression"

            rule {
                Keyword.with
                thisParser.inBraces
            }.map { Self.tryWith(tried, $0) } <?> "try with expression"

            rule {
                Keyword.cast
                Keyword.as
                Type.self
                rule {
                    Pattern.self
                    Sign.logicArrow
                    thisParser
                }.inBraces <?> "pattern match clause"
                Keyword.with
                thisParser.inBraces
            }.map { (type, clause, expression) in
                Self.tryCastAs(tried, type, clause.0, clause.1, with: expression)
            } <?> "`try cast with` expression"
        }}
    }

    static let postfixDot: Parser<(Self) -> Self> =
        Sign.dot.parser.flatMap { () in
            alternatives {
                lexer.natural.map { number in { Self.dotTuple ($0, number   ) } }
                Identifier.map { attribute in { Self.dotRecord($0, attribute) } }
            }
        }

    @ParserBuilder
    static func ascription(cast: Bool) -> Parser<(Self) -> Self> {
        if cast { Keyword.cast }
        Keyword.as
        // techinacally it should be Type2, but now just leave as a full type
        Type.self.map { type in
            { (cast ? Self.typeCast : Self.typeAscription) ($0, type) }
        } <?> "type \(cast ? "cast" : "ascription")"
    }

    @ParserBuilder
    static func applicationPostfix(using thisParser: Parser<Self>) -> Parser<(Self) -> Self> {
        thisParser
            .commaSeparated
            .inParens
            .map { arguments in { Self.application($0, arguments) } }
    }

    static let typeApplicationPostfix: Parser<(Self) -> Self> = Type
        .parser
        .commaSeparated
        .inBrackets
        .map { types in { Self.typeApplication($0, types) } }
}
