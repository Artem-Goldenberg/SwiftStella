@preconcurrency import SwiftParsec

extension Stella.`Type`: StaticParsable {
    // thiss is no jokes about calling a recursive parser this way ONLY
    // if you just try to call it recursively as a static variable, it will crash hard
    static let parser: Parser<Self> = .recursive { typeParser in
        alternatives {
            Keyword.auto.map { Self.auto } <?> "auto type"
            function(using: typeParser)
            forall(using: typeParser)
            recursive(using: typeParser)
            // other cases are handled by a special expression parser
            typeExpression(using: typeParser)
        }
    } <?> "type"

    // operators on types, in decreasing priority
    static let operatorTable: OperatorTable<Source, (), Type> = [
        [ .prefix(Sign.ampersand.map { Self.reference } <?> "reference type") ],
        [ .infix(Sign.plus.map { Self.sum } <?> "sum type", .none) ],
    ]

    @AlternativesBuilder
    static func basicType(using typeParser: Parser<Self>) -> Parser<Self> {
        typeParser.inParens

        tupleOrRecordContents(
            using: typeParser, forTuple: Self.tuple, forRecord: Self.record,
            recordFieldSeparator: .colon, descriptionSuffix: " type"
        ).inBraces

        // [int]
        typeParser.inBrackets.map(Self.list) <?> "list type"

        // <| a, b : bool, c : int |>
        rule { // `a: int` field for variant
            Identifier.self
            rule { // optional `: int`
                Sign.colon
                typeParser
            }.optional <?> "optional typing"
        }
        .commaSeparated
        .inClips
        .map(Self.variant) <?> "variant type"

        Keyword.Bool.map { Self.bool   } <?> "bool type"
        Keyword.Nat .map { Self.nat    } <?> "nat type"
        Keyword.Unit.map { Self.unit   } <?> "unit type"
        Keyword.Top .map { Self.top    } <?> "top type"
        Keyword.Bot .map { Self.bottom } <?> "bot type"

        Identifier.map(Self.variable) <?> "type variable"
    }

    // parsec provides tools for quickly parsing expressions
    static func typeExpression(using typeParser: Parser<Self>) -> Parser<Self> {
        operatorTable.makeExpressionParser { _ in
            basicType(using: typeParser)
        }
    }

    static func function(using typeParser: Parser<Type>) -> Parser<Type> {
        rule {
            Keyword.fn
            typeParser
                .commaSeparated
                .inParens
            Sign.arrow
            typeParser
        }.map(Self.function) <?> "function type"
    }

    static func forall(using typeParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.forall
            Identifier.parser.commaSeparated
            Sign.dot
            typeParser
        }.map(Self.forall) <?> "forall type"
    }

    static func recursive(using typeParser: Parser<Self>) -> Parser<Self> {
        rule {
            Keyword.µ
            Identifier.self
            Sign.dot
            typeParser
        }.map(Self.µ) <?> "µ type"
    }
}
