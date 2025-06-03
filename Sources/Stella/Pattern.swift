/// Enum for Stella's patterns
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

extension Pattern: Equatable {
    /// Syntactic equality on patterns (except for record patterns, the order of fields in those does not matter)
    public static func == (a: Pattern, b: Pattern) -> Bool {
        switch (a, b) {
        case let (.cast(p1, type1), .cast(p2, type2)):
            p1 == p2 && type1 == type2
        case let (.ascription(p1, type1), .ascription(p2, type2)):
            p1 == p2 && type1 == type2
        case let (.variant(name1, p1), .variant(name2, p2)):
            name1 == name2 && p1 == p2
        case let (.inl(p1), .inl(p2)): p1 == p2
        case let (.inr(p1), .inr(p2)): p1 == p2
        case let (.tuple(ps1), .tuple(ps2)): ps1 == ps2
        case let (.record(binds1), .record(binds2)): compareFields(binds1, binds2)
        case let (.list(ps1), .list(ps2)): ps1 == ps2
        case let (.cons(h1, t1), .cons(h2, t2)): h1 == h2 && t1 == t2
        case (.false, .false): true
        case (.true, .true): true
        case (.unit, .unit): true
        case let (.int(n1), .int(n2)): n1 == n2
        case let (.succ(p1), .succ(p2)): p1 == p2
        case let (.var(name1), .var(name2)): name1 == name2
        default: false
        }
    }

    private static func compareFields(
        _ binds1: [(Identifier, Pattern)],
        _ binds2: [(Identifier, Pattern)]
    ) -> Bool {
        guard binds1.count == binds2.count else {
            return false
        }
        struct Internal: Error {}

        let patterns1: [Identifier: Pattern]
        do {
            patterns1 = try Dictionary(
                binds1,
                uniquingKeysWith: { _,_ in throw Internal() }
            )
        } catch { return false }

        for (name2, pattern2) in binds2 {
            guard let pattern1 = patterns1[name2] else {
                return false
            }
            if pattern1 != pattern2 {
                return false
            }
        }

        return true
    }
}

extension Pattern: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.erased)
        switch self {
        case .cast(let pattern, let `as`):
            hasher.combine(pattern)
            hasher.combine(`as`)
        case .ascription(let pattern, let type):
            hasher.combine(pattern)
            hasher.combine(type)
        case .variant(let identifier, let pattern):
            hasher.combine(identifier)
            hasher.combine(pattern)
        case .inl(let pattern):
            hasher.combine(pattern)
        case .inr(let pattern):
            hasher.combine(pattern)
        case .tuple(let array):
            hasher.combine(array)
        case .record(let array):
            array.forEach { (name, pattern) in
                hasher.combine(name)
                hasher.combine(pattern)
            }
        case .list(let array):
            hasher.combine(array)
        case .cons(let pattern, let pattern2):
            hasher.combine(pattern)
            hasher.combine(pattern2)
        case .int(let int):
            hasher.combine(int)
        case .succ(let pattern):
            hasher.combine(pattern)
        case .var(let identifier):
            hasher.combine(identifier)
        default: return
        }
    }
}

extension Pattern {
    public enum Erased {
        case cast
        case ascription
        case variant
        case inl
        case inr
        case tuple
        case record
        case list
        case cons
        case `false`
        case `true`
        case unit
        case int
        case succ
        case `var`
    }

    public var erased: Erased {
        switch self {
        case .cast: .cast
        case .ascription: .ascription
        case .variant: .variant
        case .inl: .inl
        case .inr: .inr
        case .tuple: .tuple
        case .record: .record
        case .list: .list
        case .cons: .cons
        case .false: .false
        case .true: .true
        case .unit: .unit
        case .int: .int
        case .succ: .succ
        case .var: .var
        }
    }
}
