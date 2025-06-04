
/// This protocol is not really used, just a dummy to unite all abstract syntax nodes for documentation
public protocol Syntax {
    static var documentingName: String { get }
    /// Pretty-printed stella code from a syntax tree
    var code: String { get }
}

/// Stella Identifier
public struct Identifier: Syntax, Hashable {
    public let value: String
    public static let documentingName = "identifier"
    /// Public initializer to create artificial identifiers for comparison with the program ones
    public init(_ value: String) {
        self.value = value
    }
}

/**
 The root syntax element of Stella language.

 Use `Program.parser` attribute to get a Parsec parser for the whole Stella programs.
 */
public struct Program: Syntax {
    public let languageDeclaration: LanguageDeclaration
    public let extensions: [LanguageExtension]
    public let declarations: [Declaration]

    /// Public initializer so users can create artificial programs if they want
    public init(
        languageDeclaration: LanguageDeclaration,
        extensions: [LanguageExtension],
        declarations: [Declaration]
    ) {
        self.languageDeclaration = languageDeclaration
        self.extensions = extensions
        self.declarations = declarations
    }

    public static let documentingName = "program"
}

/// `language core;` at the start of the program
public enum LanguageDeclaration: Syntax {
    case languageCore

    public static let documentingName = "language declaration"
}

/// a single `extend with ...;` at the start of the program
public struct LanguageExtension: Syntax {
    public let names: [Name]

    public init(with names: [Name]) {
        self.names = names
    }

    public struct Name: Syntax, Hashable {
        public let value: String
        public static let documentingName = "language extension name"

        public init(_ value: String) {
            self.value = value
        }
    }

    public static let documentingName = "language extension"
}

/**
 Cases of that enum represent all declarations in Stella.

 We do not create separate structs for each declaration like the function declaration below,
 instead we are using different associated values for each enum case to store the tree.
*/
public enum Declaration: Syntax {
    /// Notice here, how each attribute of the function is stored like an associated value of this case
    indirect case function(
        annotations: [Annotation],
        name: Identifier,
        parameters: [Parameter],
        returnType: Type?,
        throwTypes: [Type],
        body: [Declaration],
        return: Expression
    )

    indirect case genericFunction(
        annotations: [Annotation],
        name: Identifier,
        typeVariables: [Identifier],
        parameters: [Parameter],
        returnType: Type?,
        throwTypes: [Type],
        body: [Declaration],
        return: Expression
    )

    case typeAlias(name: Identifier, type: Type)
    case exceptionType(Type)
    case exceptionVariant(name: Identifier, type: Type)

    public enum Annotation {
        case inline
    }

    public struct Parameter {
        public let name: Identifier
        public let type: Type
    }

    public static let documentingName = "declaration"
}

/**
 Enum representing all Stella's expressions, including builtin functions like `Nat::rec`
 */
public indirect enum Expression: Syntax {
    case sequence(Expression, Expression)
    case assign(Expression, Expression)
    case `if`(condition: Expression, then: Expression, else: Expression)
    case `let`([(Pattern, Expression)], Expression)
    case letrec([(Pattern, Expression)], Expression)
    case typeAbstraction([Identifier], Expression)
    case lessThan(Expression, Expression)
    case lessThanOrEqual(Expression, Expression)
    case greaterThan(Expression, Expression)
    case greaterThanOrEqual(Expression, Expression)
    case equal(Expression, Expression)
    case notEqual(Expression, Expression)
    case typeAscription(Expression, Type)
    case typeCast(Expression, Type)
    case abstraction([Declaration.Parameter], Expression)
    case variant(Identifier, Expression?)
    case match(Expression, [(Pattern, Expression)])
    case list([Expression])
    case add(Expression, Expression)
    case subtract(Expression, Expression)
    case logicOr(Expression, Expression)
    case multiply(Expression, Expression)
    case divide(Expression, Expression)
    case logicAnd(Expression, Expression)
    case ref(Expression)
    case deref(Expression)
    case application(Expression, [Expression])
    case typeApplication(Expression, [Type])
    case dotRecord(Expression, Identifier)
    case dotTuple(Expression, Int)
    case tuple([Expression])
    case record([(Identifier, Expression)])
    case consList(Expression, Expression)
    case head(Expression)
    case isEmpty(Expression)
    case tail(Expression)
    case panic
    case `throw`(Expression)
    case tryCatch(Expression, Pattern, Expression)
    case tryWith(Expression, Expression)
    case tryCastAs(Expression, Type, Pattern, Expression, with: Expression)
    case inl(Expression)
    case inr(Expression)
    case succ(Expression)
    case logicNot(Expression)
    case pred(Expression)
    case isZero(Expression)
    case fix(Expression)
    case natRec(Expression, Expression, Expression)
    case fold(Type, Expression)
    case unfold(Type, Expression)
    case constTrue
    case constFalse
    case constUnit
    case constInt(Int)
    case constMemory(MemoryAddress)
    case `var`(Identifier)

    public static let documentingName = "expression"
}

/// Memory address in the form of `#...;`
public struct MemoryAddress: Hashable {
    public let value: String
    public init(_ value: String) {
        self.value = value
    }
}

extension Syntax {
    public var description: String {
        Self.documentingName
    }
}
