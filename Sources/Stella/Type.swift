/**
 An Enum representing Stella's types.

 We use backticks to avoid collision with Swift's `Type` keyword,
 but xcode still likes to highlight this struct as a keyword, you can use qualified `Stella.Type` name to avoid that.
 */
public enum `Type`: Syntax {
    case auto
    case bool
    case nat
    case unit
    case top
    case bottom
    case variable(Identifier)

    indirect case function(from: [Type], to: Type)

    indirect case tuple([Type])

    indirect case record([(Identifier, Type)])

    indirect case sum(left: Type, right: Type)

    indirect case list(of: Type)
    
    indirect case variant([(Identifier, Type?)])

    indirect case forall(variables: [Identifier], type: Type)

    indirect case µ(Identifier, Type)

    indirect case reference(Type)


    public static let documentingName: String = "type"
}


extension Type: Equatable {
    /// Syntactic equivalence on types
    public static func == (a: Type, b: Type) -> Bool {
        switch (a, b) {
        case (.auto, .auto): return true
        case (.bool, .bool): return true
        case (.nat, .nat): return true
        case (.unit, .unit): return true
        case (.top, .top): return true
        case (.bottom, .bottom): return true
        case (.variable(let id1), .variable(let id2)):
            return id1 == id2
        case (.function(let from1, let to1), .function(let from2, let to2)):
            return from1 == from2 && to1 == to2
        case (.tuple(let array1), .tuple(let array2)):
            return array1 == array2
        case (.record(let fields1), .record(let fields2)):
            // record fields order matters
            return zip(fields1, fields2).allSatisfy { (tup1, tup2) in
                tup1.0 == tup2.0 && tup1.1 == tup2.1
            }
        case (.sum(let left1, let right1), .sum(let left2, let right2)):
            // sums are non-commutative
            return left1 == left2 && right1 == right2
        case (.list(let type1), .list(let type2)):
            return type1 == type2
        case (.variant(let array1), .variant(let array2)):
            // order in variants matters as well
            return zip(array1, array2).allSatisfy { (tup1, tup2) in
                tup1.0 == tup2.0 && tup1.1 == tup2.1
            }
        case (.forall(let vars1, let type1), .forall(let vars2, let type2)):
            return vars1 == vars2 && type1 == type2 // TODO: alpha equivalance??
        case (.µ(let id1, let type1), .µ(let id2, let type2)):
            return id1 == id2 && type1 == type2 // TODO: alpha as well??
        case (.reference(let type1), .reference(let type2)):
            return type1 == type2
        default:
            return false
        }
    }
}

extension Type: Hashable {
    private var order: Int {
        switch self {
        case .auto: 1
        case .bool: 2
        case .nat: 3
        case .unit: 4
        case .top: 5
        case .bottom: 6
        case .variable: 7
        case .function: 8
        case .tuple: 9
        case .record: 10
        case .sum: 11
        case .list: 12
        case .variant: 13
        case .forall: 14
        case .µ: 15
        case .reference: 16
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.order)
        switch self {
        case .variable(let identifier):
            hasher.combine(identifier)
        case .function(let from, let to):
            hasher.combine(from)
            hasher.combine(to)
        case .tuple(let array):
            array.forEach { hasher.combine($0) }
        case .record(let array):
            array.forEach { (name, type) in
                hasher.combine(name)
                hasher.combine(type)
            }
        case .sum(let left, let right):
            hasher.combine(left)
            hasher.combine(right)
        case .list(let of):
            hasher.combine(of)
        case .variant(let array):
            array.forEach { (name, type) in
                hasher.combine(name)
                hasher.combine(type)
            }
        case .forall(let variables, let type):
            hasher.combine(variables)
            hasher.combine(type)
        case .µ(let identifier, let type):
            hasher.combine(identifier)
            hasher.combine(type)
        case .reference(let type):
            hasher.combine(type)
        default: return
        }
    }
}
