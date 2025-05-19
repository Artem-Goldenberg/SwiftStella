@preconcurrency import SwiftParsec

// expr = single ; expr?
// block = single (; block)?
// expr = block
// block = single (; (block)?)?
// expr = single
// expr = single ;
// expr = single ; block

func flatten<T>(_ doubleOptional: T??) -> T? {
    doubleOptional?.flatMap { $0 }
}

extension Stella.Expression {
    typealias ThisParser = Parser<Self>
    typealias Operations = OperatorTable<Source, (), Self>

    public static let parser: Parser<Self> = .recursive { expression in
        rule {
            single(using: expression)
            Sign.semicolon.parser.flatMap {
                expression.optional
            }.optional.map(flatten) // convert double optional to just optional
        }.map { (expr, nextExpr) in
            guard let nextExpr else { return expr }
            return .sequence(expr, nextExpr)
        } <?> "expresssion"
    }

    // singular = Expr1
    static func single(using expression: ThisParser) -> ThisParser {
        .recursive { singular in
            alternatives {
                ifExpression(using: singular)
                letExpression(using: expression, recursive: false)
                letExpression(using: expression, recursive: true)
                generic(using: expression)
                // expr := expr
                rule {
                    conditional(using: expression)
                    rule { // we parse `:= expr` as an optional prefix to avoid backtracking
                        Sign.colonEquals
                        singular
                    }.optional
                }.map { (expr, assignedExpr) in
                    guard let assignedExpr else { return expr }
                    return .assign(expr, assignedExpr)
                } <?> "assignment"
            }
        }
    }

    // conditional ~ Expr2
    static func conditional(using expression: ThisParser) -> ThisParser {
        comparisonOperations.makeExpressionParser { conditional in
            term(using: expression, conditional: conditional)
        }
    }

    // term = Expr3
    // but we do not parse expressions like `3 as Int + 4` it's hard and likely not inteded
    static func term(using expression: ThisParser, conditional: ThisParser) -> ThisParser {
        .recursive { term in
            rule {
                alternatives {
                    lambda(using: expression)
                    variant(using: expression)
                    match(using: expression)
                    list(using: expression)
                    arithmeticOperations.makeExpressionParser { arithmetic in
                        factor(using: expression)
                    }
                }
                alternatives { // arbitrary many suffixes of cast as or as
                    ascription(cast: false)
                    ascription(cast: true)
                }.many // each gives us a transforming function, apply them in order
            }.map { (term, suffixes) in
                suffixes.reduce(term) { result, suffix in
                    suffix(result)
                }
            } // map
        } // recursive
    }

    // factor = Expr5
    static func factor(using expression: ThisParser) -> ThisParser {
        .recursive { factor in
            alternatives {
                call(of: .new, mapping: Self.ref, with: expression)
                rule { // here we can afford to call factor parser directly as it is
                    // prefixed by a star, no infinite recursion is possible
                    Sign.star
                    factor
                }.map(Self.deref) <?> "dereference"
                suffix(using: expression)
            }
        }
    }

    // suffix = Expr6
    static func suffix(using expression: ThisParser) -> ThisParser {
        rule {
            enclosed(using: expression)
            // again, parse any number of suffixes after the core expression
            // and then apply gained functions from left to right to get the expression
            alternatives {
                applicationPostfix(using: expression)
                typeApplicationPostfix
                postfixDot
            }.many
        }.map { expr, suffixes in suffixes.reduce(expr) { $1($0) } }
    }

    @AlternativesBuilder // enclosed = Expr6, but without suffix rules
    static func enclosed(using expression: ThisParser) -> ThisParser {
        tupleOrRecordContents(
            using: expression, forTuple: Self.tuple, forRecord: Self.record,
            descriptionSuffix: " expression"
        ).inBraces

        call(of: .new, mapping: Self.ref, with: expression)
        call(of: .cons, mapping: Self.consList) {
            expression
            Sign.comma
            expression
        }

        Keyword.panic.map { Self.panic }

        tryExpression(using: expression)

        call(of: .throw, mapping: Self.throw, with: expression)

        call(of: .ListHead, mapping: Self.head, with: expression)
        call(of: .ListIsEmpty, mapping: Self.isEmpty, with: expression)
        call(of: .ListTail, mapping: Self.tail, with: expression)

        call(of: .inl, mapping: Self.inl, with: expression)
        call(of: .inr, mapping: Self.inr, with: expression)

        call(of: .succ, mapping: Self.succ, with: expression)
        call(of: .not, mapping: Self.logicNot, with: expression)

        call(of: .NatPred, mapping: Self.pred, with: expression)
        call(of: .NatIszero, mapping: Self.isZero, with: expression)

        call(of: .fix, mapping: Self.fix, with: expression)
        call(of: .NatRec, mapping: Self.natRec) {
            expression
            Sign.comma
            expression
            Sign.comma
            expression
        }

        rule {
            Keyword.fold
            Type.parser.inBrackets
            basic(using: expression)
        }.map(Self.fold)

        rule {
            Keyword.unfold
            Type.parser.inBrackets
            basic(using: expression)
        }.map(Self.unfold)

        basic(using: expression)
    }

    @AlternativesBuilder // basic = Expr7
    static func basic(using expression: ThisParser) -> ThisParser {
        expression.inParens

        Keyword.true .map { Self.constTrue  }
        Keyword.false.map { Self.constFalse }
        Keyword.unit .map { Self.constUnit  }

        lexer.integer.map(Self.constInt)

        Identifier.map(Self.var)
        MemoryAddress.map(Self.constMemory)
    }

    static let comparisonOperations: Operations = [
        [
            .infix(Sign.less.map { Self.lessThan }, .none),
            .infix(Sign.lessEq.map { Self.lessThanOrEqual }, .none),
            .infix(Sign.greater.map { Self.greaterThan }, .none),
            .infix(Sign.greaterEq.map { Self.greaterThanOrEqual }, .none),
            .infix(Sign.doubleEquals.map { Self.equal }, .none),
            .infix(Sign.notEquals.map { Self.notEqual }, .none),
        ]
    ]

    static let arithmeticOperations: Operations = [
        [
            .infix(Sign.star.map   { Self.multiply }, .left),
            .infix(Sign.slash.map  { Self.divide   }, .left),
            .infix(Keyword.and.map { Self.logicAnd }, .left)
        ],
        [
            .infix(Sign.plus.map  { Self.add      }, .left),
            .infix(Sign.minus.map { Self.subtract }, .left),
            .infix(Keyword.or.map { Self.logicOr  }, .left)
        ]
    ]

}
