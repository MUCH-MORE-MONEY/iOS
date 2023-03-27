// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum MMMFontFamily {
  public enum Pretendard {
    public static let black = MMMFontConvertible(name: "Pretendard-Black", family: "Pretendard", path: "Pretendard-Black.otf")
    public static let bold = MMMFontConvertible(name: "Pretendard-Bold", family: "Pretendard", path: "Pretendard-Bold.otf")
    public static let extraBold = MMMFontConvertible(name: "Pretendard-ExtraBold", family: "Pretendard", path: "Pretendard-ExtraBold.otf")
    public static let extraLight = MMMFontConvertible(name: "Pretendard-ExtraLight", family: "Pretendard", path: "Pretendard-ExtraLight.otf")
    public static let light = MMMFontConvertible(name: "Pretendard-Light", family: "Pretendard", path: "Pretendard-Light.otf")
    public static let medium = MMMFontConvertible(name: "Pretendard-Medium", family: "Pretendard", path: "Pretendard-Medium.otf")
    public static let regular = MMMFontConvertible(name: "Pretendard-Regular", family: "Pretendard", path: "Pretendard-Regular.otf")
    public static let semiBold = MMMFontConvertible(name: "Pretendard-SemiBold", family: "Pretendard", path: "Pretendard-SemiBold.otf")
    public static let thin = MMMFontConvertible(name: "Pretendard-Thin", family: "Pretendard", path: "Pretendard-Thin.otf")
    public static let all: [MMMFontConvertible] = [black, bold, extraBold, extraLight, light, medium, regular, semiBold, thin]
  }
  public static let allCustomFonts: [MMMFontConvertible] = [Pretendard.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct MMMFontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return Bundle.module.url(forResource: path, withExtension: nil)
  }
}

public extension MMMFontConvertible.Font {
  convenience init?(font: MMMFontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(macOS)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}
// swiftlint:enable all
// swiftformat:enable all
