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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.erased)
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

extension Type {
    public enum Erased {
        case auto
        case bool
        case nat
        case unit
        case top
        case bottom
        case variable
        case function
        case tuple
        case record
        case sum
        case list
        case variant
        case forall
        case µ
        case reference
    }

    public var erased: Erased {
        switch self {
        case .auto: .auto
        case .bool: .bool
        case .nat: .nat
        case .unit: .unit
        case .top: .top
        case .bottom: .bottom
        case .variable: .variable
        case .function: .function
        case .tuple: .tuple
        case .record: .record
        case .sum: .sum
        case .list: .list
        case .variant: .variant
        case .forall: .forall
        case .µ: .µ
        case .reference: .reference
        }
    }
}
