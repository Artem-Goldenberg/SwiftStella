extension Identifier {
    public var code: String { value }
}

extension DefaultStringInterpolation {
    // This extension is a life saver!!!
    // got it from: https://forums.swift.org/t/multi-line-string-nested-indentation-with-interpolation/36933
    mutating func appendInterpolation(indented string: String) {
        let indent = String(stringInterpolation: self)
            .reversed()
            .prefix {" \t".contains($0)}
        if indent.isEmpty {
            appendInterpolation(string)
        } else {
            appendLiteral(
                string.split(
                    separator: "\n",
                    omittingEmptySubsequences: false
                ).joined(separator: "\n" + indent)
            )
        }
    }

    mutating func appendInterpolation(lines: Int, _ string: String) {
        if string.isEmpty {
            appendLiteral("\\")
        } else {
            for _ in 1..<lines {
                self.appendLiteral("\n")
            }
            self.appendInterpolation(string)
        }
    }
}

extension Program {
    public var code: String {
        """
        \(languageDeclaration.code)
        \(lines: 2, extensions.map(\.code).joined(separator: "\n"))
        
        \(declarations.map(\.code).joined(separator: "\n\n"))
        """.replacingOccurrences(of: "\\\n", with: "")
    }
}

extension LanguageDeclaration {
    public var code: String {
        switch self {
        case .languageCore: return "language core;"
        }
    }
}

extension LanguageExtension.Name {
    public var code: String {
        "#\(value)"
    }
}

extension LanguageExtension {
    public var code: String {
        "extend with \(names.map(\.code).joined(separator: ", "));"
    }
}

extension Declaration.Annotation {
    public var code: String {
        switch self {
        case .inline: return "inline"
        }
    }
}

extension Declaration.Parameter {
    public var code: String {
        "\(name.code) : \(type.code)"
    }
}

fileprivate func functionReturnAndBody(
    _ returnType: Type?,
    _ throwTypes: [Type],
    _ body: [Declaration],
    _ returnExpr: Expression
) -> String {
    let returnMark = returnType.map { "-> \($0.code) " } ?? ""
    let throwMark = throwTypes.isEmpty ? ""
        : "throws \(throwTypes.map(\.code).joined(separator: ", ")) "

    let returnString = "return \(returnExpr.code)"

    let bodyDecls = body.isEmpty ? "" : "\(body.map(\.code).joined(separator: "\n"))\n"
    let bodyString = "\(bodyDecls)\(returnString)"
    
    return """
    \(returnMark)\(throwMark){
        \(indented: bodyString)
    }
    """
}

extension Declaration {
    public var code: String {
        switch self {
        case let .function(
            annotations, name, parameters, returnType, throwTypes, body, `return`
        ):
            """
            \(annotations.map(\.code).joined(separator: " "))\
            fn \(name.code)(\(parameters.map(\.code).joined(separator: ", "))) \
            \(functionReturnAndBody(returnType, throwTypes, body, `return`))
            """

        case let .genericFunction(
            annotations, name, typeVariables, parameters,
            returnType, throwTypes, body, `return`
        ):
            """
            \(annotations.map(\.code).joined(separator: " "))\
            generic fn \(name.code)[\(typeVariables.map(\.code).joined(separator: ", "))]\
            (\(parameters.map(\.code).joined(separator: ", "))) \
            \(functionReturnAndBody(returnType, throwTypes, body, `return`))
            """

        case let .typeAlias(name, type):
            "type \(name.code) = \(type.code)"

        case .exceptionType(let type):
            "exception type = \(type.code)"

        case .exceptionVariant(let name, let type):
            "exception variant \(name.code) : \(type.code)"

        }
    }
}

extension Pattern {
    public var code: String {
        switch self {
        case .cast(let pattern, let type):
            "\(pattern.code) cast as \(type.code)"
        case .ascription(let pattern, let type):
            "\(pattern.code) as \(type.code)"
        case .variant(let identifier, let pattern):
            "<|\(identifier.code)\(pattern.map {" = \($0.code)"} ?? "")|>"
        case .inl(let pattern):
            "inl(\(pattern.code))"
        case .inr(let pattern):
            "inr(\(pattern.code))"
        case .tuple(let patterns):
            "{\(patterns.map(\.code).joined(separator: ", "))}"
        case .record(let patterns):
            "{\(patterns.map {"\($0.code) = \($1.code)"}.joined(separator: ", "))}"
        case .list(let patterns):
            "[\(patterns.map(\.code).joined(separator: ", "))]"
        case .cons(let pattern1, let pattern2):
            "cons(\(pattern1.code), \(pattern2.code))"
        case .false: "false"
        case .true: "true"
        case .unit: "unit"
        case .int(let int):
            "\(int)"
        case .succ(let pattern):
            "succ(\(pattern.code))"
        case .var(let identifier): identifier.code
        }
    }
}

extension Type {
    public var code: String {
        switch self {
        case .auto: "auto"
        case .bool: "Bool"
        case .nat: "Nat"
        case .unit: "Unit"
        case .top: "Top"
        case .bottom: "Bot"

        case let .variable(identifier):
            identifier.code

        case let .function(from, to):
            "fn(\(from.map(\.code).joined(separator: ", "))) -> \(to.code)"

        case .tuple(let array):
            "{\(array.map(\.code).joined(separator: ", "))}"

        case .record(let array):
            "{\(array.map {"\($0.code) : \($1.code)"}.joined(separator: ", "))}"

        case .sum(let left, let right):
            "\(left.code(in: self)) + \(right.code(in: self))"

        case .list(let of):
            "[\(of.code)]"

        case .variant(let array):
            "<|\(array.map(fieldDecl).joined(separator: ", "))|>"

        case .forall(let variables, let type):
            "forall \(variables.map(\.code).joined(separator: " ")). \(type.code)"

        case .µ(let identifier, let type):
            "µ \(identifier.code). \(type.code)"

        case .reference(let type):
            "&\(type.code(in: self))"
        }
    }
}

fileprivate func fieldDecl(for label: Identifier, and type: Type?) -> String {
    guard let type else { return label.code }
    return "\(label.code) : \(type.code)"
}

fileprivate extension Type {
    func needsParens(in parent: Type) -> Bool {
        switch parent {
        case .sum:
            switch self {
                case .sum, .function, .forall, .µ: return true
                default: return false
            }
        case .reference:
            switch self {
                case .sum, .function, .forall, .µ: return true
                default: return false
            }
        default:
            return false
        }
    }

    func code(in parent: Type) -> String {
        if needsParens(in: parent) {
            return "(\(code))"
        }
        return code
    }
}

extension MemoryAddress {
    public var code: String {
        "<0x\(value)>"
    }
}
