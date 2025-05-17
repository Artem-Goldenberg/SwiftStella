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
