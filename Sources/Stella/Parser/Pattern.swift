@preconcurrency import SwiftParsec

extension Pattern: StaticParsable {
    static let parser: Parser<Self> = table.makeExpressionParser { pattern in
        alternatives {
            pattern.inParens // can be nested in meaningless parens
//            ascription(using: thisParser)
            variant(using: pattern)
            call(of: .inl, mapping: Self.inl, with: pattern) <?> "left alternative"
            call(of: .inr, mapping: Self.inr, with: pattern) <?> "right alternative"
            call(of: .succ, mapping: Self.succ, with: pattern) <?> "succ pattern"
            tupleOrRecordContents(
                using: pattern, forTuple: Self.tuple, forRecord: Self.record,
                descriptionSuffix: " pattern"
            ).inBraces
            list(using: pattern)
            constructor(using: pattern)
            basicPattern
        }
    } <?> "pattern"

    // to avoid recursion in the cast and ascription rules,
    // we need to parse patters like expressions with postfix operations
    static let table: OperatorTable<Source, (), Self> = [[
        .postfix(
            rule {
                Keyword.cast
                Keyword.as
                Type.self
            }.map { type in { Self.cast($0, as: type) } } <?> "cast"
        ),
        .postfix(
            rule {
                Keyword.as
                Type.self
            }.map { type in { Self.ascription($0, type) } } <?> "ascription"
        )
    ]]

    static func variant(using thisParser: Parser<Self>) -> Parser<Self> {
        rule {
            Identifier.self
            rule {
                Sign.equals
                thisParser
            }.optional <?> "pattern data"
        }.inClips.map(Self.variant) <?> "variant pattern"
    }

    static func list(using thisParser: Parser<Self>) -> Parser<Self> {
        thisParser
            .commaSeparated
            .inBrackets
            .map(Self.list) <?> "list pattern"
    }

    static func constructor(using thisParser: Parser<Self>) -> Parser<Self> {
        // there are some weird rules regarding this branch:
        // PatternCons.    Pattern ::= "cons" "(" Pattern "," Pattern ")" ;
        // patternCons.    Pattern ::= "(" Pattern "," Pattern ")" ;
        // define patternCons h t = PatternCons h t ;
        // no idea, what the last two mean, and it would be really difficult to parse
        // the `(pattern, pattern)` as one pattern expression, so not using this one
        rule {
            Keyword.cons
            rule {
                thisParser
                Sign.comma
                thisParser
            }.inParens
        }.map(Self.cons) <?> "cons pattern"
    }

    static let basicPattern: Parser<Self> = alternatives {
        Keyword.true.map  { Self.true }
        Keyword.false.map { Self.false }
        Keyword.unit.map  { Self.unit }
        Identifier.map(Self.var)
        lexer.integer.map(Self.int)
    }
}
