
/// This protocol is not really used, just a dummy to unite all abstract syntax nodes for documentation
public protocol Syntax {
    static var documentingName: String { get }
}

extension Syntax {
    public var description: String {
        Self.documentingName
    }
}

public struct Identifier: Syntax {
    let value: String
    public static let documentingName = "identifier"
}

public struct Program: Syntax {
    public let languageDeclaration: LanguageDeclaration
    public let extensions: [LanguageExtension]
    public let declarations: [Declaration]

    public static let documentingName = "program"
}

public enum LanguageDeclaration: Syntax {
    case languageCore

    public static let documentingName = "language declaration"
}

public struct LanguageExtension: Syntax {
    public let names: [Name]

    public struct Name {
        public let value: String
    }

    public static let documentingName = "language extension"
}

public enum Declaration: Syntax {
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
        let name: Identifier
        let type: Type
    }

    public static let documentingName = "declaration"
}

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

public indirect enum Pattern: Syntax {
    case cast(Pattern, as: Type)
    case ascription(Pattern, Type)
    case variant(Identifier, Pattern?)
    case inl(Pattern)
    case inr(Pattern)
    case tuple([Pattern])
    case record([(Identifier, Pattern)])
    case list([Pattern])
    case cons(Pattern, Pattern)
    case `false`
    case `true`
    case unit
    case int(Int)
    case succ(Pattern)
    case `var`(Identifier)

    public static let documentingName = "pattern"
}

public struct MemoryAddress {
    let value: String
}
