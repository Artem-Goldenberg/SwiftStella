extension Program {
    /// Fast creation of a program
    ///
    /// Groupped with other extensions here,
    /// this allows for fast initialization of a program like this:
    ///
    /// ```swift
    /// Program(
    ///     declarations: [],
    ///     extendedWith:
    ///         ["some", "More"],
    ///         ["more", "and", "even", "more"],
    ///         LanguageExtension(with: ["some"])
    /// )
    ///  ```
    public init(
        declarations: [Declaration],
        extendedWith extensions: LanguageExtension...
    ) {
        self.init(
            languageDeclaration: .languageCore,
            extensions: extensions,
            declarations: declarations
        )
    }
}

extension Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension LanguageExtension: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Name...) {
        self.init(with: elements)
    }
}

extension LanguageExtension: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(with: [.init(value)])
    }
}

extension LanguageExtension.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension MemoryAddress: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
