@preconcurrency import SwiftParsec

// Generic ParserBuilders for the SwiftParsec parsers

public typealias Source = String
public typealias Parser<Result> = GenericParser<Source, (), Result>

public protocol Parsable {
    associatedtype Result = Self
    var parser: Parser<Result> { get }
}

public protocol StaticParsable: Parsable {
    @ParserBuilder
    static var parser: Parser<Result> { get }
}

extension Parsable where Self: StaticParsable {
    public var parser: Parser<Result> {
        Self.parser
    }
}

// this two functions are used to represent grammar rules in a concise
// way of a result builder. `rule` represents sequence of tokens
// and `alternatives` represent different ways to parse next tokens

func rule<R>(@ParserBuilder _ builder: () -> Parser<R>) -> Parser<R> {
    return builder()
}

func alternatives<R>(@AlternativesBuilder _ builder: () -> Parser<R>) -> Parser<R> {
    return builder()
}

@resultBuilder
struct ParserBuilder {
    static func buildExpression<R>(_ first: Parser<R>) -> Parser<R> {
        first
    }

    static func buildExpression<P: Parsable>(_ parsable: P) -> Parser<P.Result> {
        parsable.parser
    }

    // probably not needed
    static func buildExpression<P: StaticParsable>(_ parsable: P.Type) -> Parser<P.Result> {
        P.parser
    }

    static func buildOptional(_ component: Parser<()>?) -> Parser<()> {
        component ?? GenericParser(result: ())
    }

    static func buildPartialBlock<R>(first: Parser<R>) -> Parser<R> {
        first
    }

    // add more overloads, if types are not right in builders

    // to disambiguate next overloads
    static func buildPartialBlock(
        accumulated: Parser<()>, next: Parser<()>
    ) -> Parser<()> {
        accumulated *> next
    }

    static func buildPartialBlock<R>(
        accumulated: Parser<R>, next: Parser<()>
    ) -> Parser<R> {
        accumulated <* next
    }

    static func buildPartialBlock<R>(
        accumulated: Parser<R>, next: Parser<()?>
    ) -> Parser<R> {
        accumulated <* next
    }

    static func buildPartialBlock<R>(
        accumulated: Parser<()>, next: Parser<R>
    ) -> Parser<R> {
        accumulated *> next
    }

    static func buildPartialBlock<R1, R2>(
        accumulated: Parser<R1>, next: Parser<R2>
    ) -> Parser<(R1, R2)> {
        accumulated.flatMap { r1 in
            next.map { r2 in
                (r1, r2)
            }
        }
    }

    // actually such overloads cause problems, so can't add these
//    static func buildPartialBlock<R1, R2, R3>(
//        accumulated: Parser<R1>, next: Parser<(R2, R3)>
//    ) -> Parser<(R1, R2, R3)> {
//        accumulated.flatMap { r1 in
//            next.map { (r2, r3) in
//                (r1, r2, r3)
//            }
//        }
//    }

    static func buildPartialBlock<R1, R2, R3>(
        accumulated: Parser<(R1, R2)>, next: Parser<R3>
    ) -> Parser<(R1, R2, R3)> {
        accumulated.flatMap { (r1, r2) in
            next.map { r3 in
                (r1, r2, r3)
            }
        }
    }

    static func buildPartialBlock<R1, R2>(
        accumulated: Parser<(R1, R2)>, next: Parser<()>
    ) -> Parser<(R1, R2)> {
        accumulated <* next
    }

    static func buildPartialBlock<R1, R2, R3, R4>(
        accumulated: Parser<(R1, R2, R3)>, next: Parser<R4>
    ) -> Parser<(R1, R2, R3, R4)> {
        accumulated.flatMap { (r1, r2, r3) in
            next.map { r4 in
                (r1, r2, r3, r4)
            }
        }
    }

    static func buildPartialBlock<R1, R2, R3, R4, R5>(
        accumulated: Parser<(R1, R2, R3, R4)>, next: Parser<R5>
    ) -> Parser<(R1, R2, R3, R4, R5)> {
        accumulated.flatMap { (r1, r2, r3, r4) in
            next.map { r5 in
                (r1, r2, r3, r4, r5)
            }
        }
    }

    static func buildPartialBlock<R1, R2, R3, R4, R5, R6>(
        accumulated: Parser<(R1, R2, R3, R4, R5)>, next: Parser<R6>
    ) -> Parser<(R1, R2, R3, R4, R5, R6)> {
        accumulated.flatMap { (r1, r2, r3, r4, r5) in
            next.map { r6 in
                (r1, r2, r3, r4, r5, r6)
            }
        }
    }

}

@resultBuilder
struct AlternativesBuilder {
    static func buildExpression<P: Parsable>(_ expression: P) -> Parser<P.Result> {
        expression.parser
    }

    // probably not needed as well
    static func buildExpression<P: StaticParsable>(_ expression: P) -> Parser<P.Result> {
        P.parser
    }

    static func buildExpression<R>(_ parser: Parser<R>) -> Parser<R> {
        parser
    }

    static func buildPartialBlock<R>(first: Parser<R>) -> Parser<R> {
        first
    }

    static func buildPartialBlock<R>(
        accumulated: Parser<R>, next: Parser<R>
    ) -> Parser<R> {
        accumulated.alternative(next)
    }
}
