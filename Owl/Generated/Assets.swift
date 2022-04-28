// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal enum Blue {
      internal static let _1 = ColorAsset(name: "Blue/1")
      internal static let _2 = ColorAsset(name: "Blue/2")
      internal static let _3 = ColorAsset(name: "Blue/3")
      internal static let _4 = ColorAsset(name: "Blue/4")
      internal static let _5 = ColorAsset(name: "Blue/5")
      internal static let _6 = ColorAsset(name: "Blue/6")
      internal static let _7 = ColorAsset(name: "Blue/7")
    }
    internal static let darkGray = ColorAsset(name: "DarkGray")
    internal static let light = ColorAsset(name: "Light")
    internal enum Loader {
      internal static let first = ColorAsset(name: "Loader/first")
      internal static let second = ColorAsset(name: "Loader/second")
      internal static let third = ColorAsset(name: "Loader/third")
    }
    internal enum Pink {
      internal static let _1 = ColorAsset(name: "Pink/1")
      internal static let _10 = ColorAsset(name: "Pink/10")
      internal static let _11 = ColorAsset(name: "Pink/11")
      internal static let _2 = ColorAsset(name: "Pink/2")
      internal static let _3 = ColorAsset(name: "Pink/3")
      internal static let _4 = ColorAsset(name: "Pink/4")
      internal static let _5 = ColorAsset(name: "Pink/5")
      internal static let _6 = ColorAsset(name: "Pink/6")
      internal static let _7 = ColorAsset(name: "Pink/7")
      internal static let _8 = ColorAsset(name: "Pink/8")
      internal static let _9 = ColorAsset(name: "Pink/9")
    }
    internal enum Purple {
      internal static let _1 = ColorAsset(name: "Purple/1")
      internal static let _2 = ColorAsset(name: "Purple/2")
      internal static let _3 = ColorAsset(name: "Purple/3")
      internal static let _4 = ColorAsset(name: "Purple/4")
      internal static let _5 = ColorAsset(name: "Purple/5")
      internal static let _6 = ColorAsset(name: "Purple/6")
      internal static let _7 = ColorAsset(name: "Purple/7")
    }
    internal static let textFieldBackground = ColorAsset(name: "TextFieldBackground")
    internal static let violet = ColorAsset(name: "Violet")
  }
  internal enum Images {
    internal static let gradientOwl = ImageAsset(name: "GradientOwl")
    internal static let nastya = ImageAsset(name: "Nastya")
    internal static let owlBlack = ImageAsset(name: "OwlBlack")
    internal static let owlWithPadding = ImageAsset(name: "OwlWithPadding")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
