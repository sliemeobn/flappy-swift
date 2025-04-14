import ElementaryCSS

extension CSSColor {
    static let background: Self = "var(--color-background)"
    static let backgroundTransparent: Self = "var(--color-background-transparent)"
    static let foreground: Self = "var(--color-foreground)"
    static let orange: Self = "var(--color-orange)"
    static let purple: Self = "var(--color-purple)"
}

extension CSSFontSize {
    static let sm = CSSFontSize(.rem(0.875))
    static let lg = CSSFontSize(.rem(1.125))
    static let xl = CSSFontSize(.rem(1.25))
    static let xxl = CSSFontSize(.rem(1.5))
}
