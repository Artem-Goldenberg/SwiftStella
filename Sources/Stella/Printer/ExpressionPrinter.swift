fileprivate extension Expression {
    var level: Int {
        switch self {
        case .sequence, .let, .letrec, .typeAbstraction: 0
        case .assign, .if: 1
        case .lessThan, .lessThanOrEqual: 2
        case .greaterThan, .greaterThanOrEqual: 2
        case .equal, .notEqual: 2
        case .typeAscription, .typeCast, .abstraction: 3
        case .variant, .match, .list, .add, .subtract, .logicOr: 3
        case .multiply, .divide, .logicAnd: 4
        case .ref, .deref: 5
        case .application, .typeApplication, .dotRecord, .dotTuple, .tuple, .record: 6
        case .consList, .head, .isEmpty, .tail, .panic, .throw, .tryCatch, .tryWith: 6
        case .tryCastAs, .inl, .inr, .succ, .logicNot, .pred, .isZero: 6
        case .fix, .natRec, .fold, .unfold: 6
        case .constTrue, .constFalse, .constUnit, .constInt, .constMemory, .var: 7
        }
    }

    func code(on level: Int) -> String {
        if self.level < level {
            return "(\(code))"
        }
        return "\(code)"
    }
}

fileprivate func patternBinding(pattern: Pattern, expr: Expression) -> String {
    "\(pattern.code) = \(expr.code)"
}

fileprivate func patternBranch(pattern: Pattern, expr: Expression) -> String {
    "\(pattern.code) => \(expr.code)"
}

fileprivate func recordBinding(label: Identifier, expr: Expression) -> String {
    "\(label.code) = \(expr.code)"
}

extension Expression {
    public var code: String {
        switch self {
        case .constTrue: "true"
        case .constFalse: "false"
        case .constUnit: "unit"
        case .constInt(let int): "\(int)"
        case .constMemory(let address): address.code
        case .var(let identifier): identifier.code
        case .sequence(let expression1, let expression2):
            "\(expression1.code(on: 1)); \(expression2.code)" // code(on: 0) == code
        case .assign(let expression1, let expression2):
            "\(expression1.code(on: 2)) := \(expression2.code(on: 1))"
        case .if(let condition, let then, let `else`):
            "if \(condition.code(on: 1)) then \(then.code(on: 1)) else \(`else`.code(on: 1))"
        case .let(let bindings, let expr):
            "let \(bindings.map(patternBinding).joined(separator: ", ")) in \(expr.code)"
        case .letrec(let bindings, let expr):
            "letrec \(bindings.map(patternBinding).joined(separator: ", ")) in \(expr.code)"
        case .typeAbstraction(let vars, let expr):
            "generic[\(vars.map(\.code).joined(separator: ", "))] \(expr.code)"
        case .lessThan(let expression, let expression2):
            "\(expression.code(on: 3)) < \(expression2.code(on: 3))"
        case .lessThanOrEqual(let expression, let expression2):
            "\(expression.code(on: 3)) <= \(expression2.code(on: 3))"
        case .greaterThan(let expression, let expression2):
            "\(expression.code(on: 3)) > \(expression2.code(on: 3))"
        case .greaterThanOrEqual(let expression, let expression2):
            "\(expression.code(on: 3)) >= \(expression2.code(on: 3))"
        case .equal(let expression, let expression2):
            "\(expression.code(on: 3)) == \(expression2.code(on: 3))"
        case .notEqual(let expression, let expression2):
            "\(expression.code(on: 3)) != \(expression2.code(on: 3))"
        case .typeAscription(let expression, let type):
            // formally in here and in the next one, only type2 allowed, but don't care
            "\(expression.code(on: 3)) as \(type.code)"
        case .typeCast(let expression, let type):
            "\(expression.code(on: 3)) as \(type.code)"
        case .abstraction(let params, let expression):
            """
            fn(\(params.map(\.code).joined(separator: ", "))) {
                return \(indented: expression.code)
            }
            """
        case .variant(let identifier, let expression):
            "<|\(identifier.code)\(expression.map {" = \($0.code)"} ?? "")|>"
        case .match(let expression, let branches):
            """
            match \(expression.code(on: 2)) {
                \(indented: branches.map(patternBranch).joined(separator: "\n| "))
            }
            """
        case .list(let array):
            "[\(array.map(\.code).joined(separator: ", "))]"
        case .add(let expression, let expression2):
            "\(expression.code(on: 3)) + \(expression2.code(on: 4))"
        case .subtract(let expression, let expression2):
            "\(expression.code(on: 3)) - \(expression2.code(on: 4))"
        case .logicOr(let expression, let expression2):
            "\(expression.code(on: 3)) or \(expression2.code(on: 4))"
        case .multiply(let expression, let expression2):
            "\(expression.code(on: 4)) * \(expression2.code(on: 5))"
        case .divide(let expression, let expression2):
            "\(expression.code(on: 4)) / \(expression2.code(on: 5))"
        case .logicAnd(let expression, let expression2):
            "\(expression.code(on: 4)) and \(expression2.code(on: 5))"
        case .ref(let expression):
            "new(\(expression.code))"
        case .deref(let expression):
            "*\(expression.code(on: 5))"
        case .application(let callee, let arguments):
            "\(callee.code(on: 6))(\(arguments.map(\.code).joined(separator: ", ")))"
        case .typeApplication(let callee, let typeArguments):
            "\(callee.code(on: 6))[\(typeArguments.map(\.code).joined(separator: ", "))]"
        case .dotRecord(let expression, let identifier):
            "\(expression.code(on: 6)).\(identifier.code)"
        case .dotTuple(let expression, let int):
            "\(expression.code(on: 6)).\(int)"
        case .tuple(let array):
            "{\(array.map(\.code).joined(separator: ", "))}"
        case .record(let fields):
            "{\(fields.map(recordBinding).joined(separator: ", "))}"
        case .consList(let expression, let expression2):
            "cons(\(expression.code), \(expression2.code))"
        case .head(let expression):
            "List::head(\(expression.code))"
        case .isEmpty(let expression):
            "List::isempty(\(expression.code))"
        case .tail(let expression):
            "List::tail(\(expression.code))"
        case .panic: "panic!"
        case .throw(let expression):
            "throw(\(expression.code))"
        case .tryCatch(let expression, let pattern, let handler):
            """
            try { 
                \(indented: expression.code)
            } catch {
                \(pattern.code) => \(indented: handler.code)
            }
            """
        case .tryWith(let expression, let handler):
            """
            try { 
                \(indented: expression.code)
            } with {
                \(indented: handler.code)
            }
            """
        case .tryCastAs(let expression, let type, let pattern, let handler, let with):
            """
            try { 
                \(indented: expression.code)
            } cast as \(type.code) {
                \(pattern.code) => \(indented: handler.code)
            } with { 
                \(indented: with.code)
            }
            """
        case .inl(let expression):
            "inl(\(expression.code))"
        case .inr(let expression):
            "inr(\(expression.code))"
        case .succ(let expression):
            "succ(\(expression.code))"
        case .logicNot(let expression):
            "not(\(expression.code))"
        case .pred(let expression):
            "Nat::pred(\(expression.code))"
        case .isZero(let expression):
            "Nat::iszero(\(expression.code))"
        case .fix(let expression):
            "fix(\(expression.code))"
        case .natRec(let iters, let ini, let step):
            "Nat::rec(\(iters.code), \(ini.code), \(step.code))"
        case .fold(let type, let expression):
            "fold[\(type.code)](\(expression.code))"
        case .unfold(let type, let expression):
            "unfold[\(type.code)](\(expression.code))"
        }
    }
}
