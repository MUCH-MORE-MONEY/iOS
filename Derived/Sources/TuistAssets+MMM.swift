// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum MMMAsset {
  public enum Color {
    public static let blue050 = MMMColors(name: "blue050")
    public static let blue100 = MMMColors(name: "blue100")
    public static let blue200 = MMMColors(name: "blue200")
    public static let blue300 = MMMColors(name: "blue300")
    public static let blue400 = MMMColors(name: "blue400")
    public static let blue500 = MMMColors(name: "blue500")
    public static let blue600 = MMMColors(name: "blue600")
    public static let blue700 = MMMColors(name: "blue700")
    public static let blue800 = MMMColors(name: "blue800")
    public static let blue900 = MMMColors(name: "blue900")
    public static let gray100 = MMMColors(name: "gray100")
    public static let gray200 = MMMColors(name: "gray200")
    public static let gray300 = MMMColors(name: "gray300")
    public static let gray400 = MMMColors(name: "gray400")
    public static let gray500 = MMMColors(name: "gray500")
    public static let gray600 = MMMColors(name: "gray600")
    public static let gray700 = MMMColors(name: "gray700")
    public static let gray800 = MMMColors(name: "gray800")
    public static let gray900 = MMMColors(name: "gray900")
    public static let orange050 = MMMColors(name: "orange050")
    public static let orange100 = MMMColors(name: "orange100")
    public static let orange200 = MMMColors(name: "orange200")
    public static let orange300 = MMMColors(name: "orange300")
    public static let orange400 = MMMColors(name: "orange400")
    public static let orange500 = MMMColors(name: "orange500")
    public static let orange600 = MMMColors(name: "orange600")
    public static let orange700 = MMMColors(name: "orange700")
    public static let orange800 = MMMColors(name: "orange800")
    public static let orange900 = MMMColors(name: "orange900")
    public static let yellow050 = MMMColors(name: "yellow050")
    public static let yellow100 = MMMColors(name: "yellow100")
    public static let yellow200 = MMMColors(name: "yellow200")
    public static let yellow300 = MMMColors(name: "yellow300")
    public static let yellow400 = MMMColors(name: "yellow400")
    public static let yellow500 = MMMColors(name: "yellow500")
    public static let yellow600 = MMMColors(name: "yellow600")
    public static let yellow700 = MMMColors(name: "yellow700")
    public static let yellow800 = MMMColors(name: "yellow800")
    public static let yellow900 = MMMColors(name: "yellow900")
    public static let red500 = MMMColors(name: "red500")
  }
  public enum Icon {
    public static let iconGroupActive = MMMImages(name: "iconGroupActive")
    public static let iconGroupInactive = MMMImages(name: "iconGroupInactive")
    public static let iconMoneyActive = MMMImages(name: "iconMoneyActive")
    public static let iconMoneyInactive = MMMImages(name: "iconMoneyInactive")
    public static let iconMypageActive = MMMImages(name: "iconMypageActive")
    public static let iconMypageInactive = MMMImages(name: "iconMypageInactive")
    public static let iconSeedActive = MMMImages(name: "iconSeedActive")
    public static let iconSeedInactive = MMMImages(name: "iconSeedInactive")
    public static let iconArrowBack24 = MMMImages(name: "iconArrowBack24")
    public static let iconArrowDown32 = MMMImages(name: "iconArrowDown32")
    public static let iconArrowDropdown16 = MMMImages(name: "iconArrowDropdown16")
    public static let iconArrowExpandLess16 = MMMImages(name: "iconArrowExpandLess16")
    public static let iconArrowExpandMore16 = MMMImages(name: "iconArrowExpandMore16")
    public static let iconArrowNext16 = MMMImages(name: "iconArrowNext16")
    public static let iconArrowNext24 = MMMImages(name: "iconArrowNext24")
    public static let iconArrowUp32 = MMMImages(name: "iconArrowUp32")
    public static let iconCamera48 = MMMImages(name: "iconCamera48")
    public static let iconCoinEarn40 = MMMImages(name: "iconCoinEarn40")
    public static let iconCoinPay40 = MMMImages(name: "iconCoinPay40")
    public static let iconDelete24 = MMMImages(name: "iconDelete24")
    public static let iconHighlightoff24 = MMMImages(name: "iconHighlightoff24")
    public static let iconPhotoBlank64 = MMMImages(name: "iconPhotoBlank64")
    public static let iconReport16 = MMMImages(name: "iconReport16")
    public static let iconStar16 = MMMImages(name: "iconStar16")
    public static let iconStar24 = MMMImages(name: "iconStar24")
    public static let iconStar36 = MMMImages(name: "iconStar36")
    public static let iconStar48 = MMMImages(name: "iconStar48")
    public static let iconMypageBg = MMMImages(name: "iconMypageBg")
    public static let iconOnboarding1 = MMMImages(name: "iconOnboarding1")
    public static let iconOnboarding2 = MMMImages(name: "iconOnboarding2")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class MMMColors {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if canImport(SwiftUI)
  private var _swiftUIColor: Any? = nil
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) var swiftUIColor: SwiftUI.Color {
    get {
      if self._swiftUIColor == nil {
        self._swiftUIColor = SwiftUI.Color(asset: self)
      }

      return self._swiftUIColor as! SwiftUI.Color
    }
    set {
      self._swiftUIColor = newValue
    }
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension MMMColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: MMMColors) {
    let bundle = MMMResources.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
  init(asset: MMMColors) {
    let bundle = MMMResources.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct MMMImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = MMMResources.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension MMMImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the MMMImages.image property")
  convenience init?(asset: MMMImages) {
    #if os(iOS) || os(tvOS)
    let bundle = MMMResources.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: MMMImages) {
    let bundle = MMMResources.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: MMMImages, label: Text) {
    let bundle = MMMResources.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: MMMImages) {
    let bundle = MMMResources.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
