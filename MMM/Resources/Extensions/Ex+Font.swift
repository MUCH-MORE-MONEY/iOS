//
//  Ex+Font.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import UIKit

public extension MMMResource {
	enum Font {
		public enum Family: String, CaseIterable {
			case regular = "Regular"
			case black = "Black"
			case medium = "Medium"
			case thin = "Thin"
			case light = "Light"
			case extraLight = "ExtraLight"
			case bold = "Bold"
			case semibold = "SemiBold"
			case extraBold = "ExtraBold"
		}
		
		public static func prtendard(family: Family = .medium, size: CGFloat = 11) -> UIFont {
			return UIFont(name: "Pretendard-\(family.rawValue)", size: size)!
		}
		
		// TODO: - lineHeight
		public static let h0 = prtendard(family: .semibold, size: 36)
		public static let h1 = prtendard(family: .bold, size: 28)
		public static let h2 = prtendard(family: .bold, size: 24)
		public static let h3 = prtendard(family: .medium, size: 28)
		public static let h4 = prtendard(family: .semibold, size: 20)
		public static let title1 = prtendard(family: .bold, size: 18)
		public static let title2 = prtendard(family: .semibold, size: 18)
		public static let title3 = prtendard(family: .bold, size: 16)
		public static let body1 = prtendard(family: .medium, size: 16)
		public static let body2 = prtendard(family: .bold, size: 14)
		public static let body3 = prtendard(family: .medium, size: 14)
		public static let body4 = prtendard(family: .bold, size: 12)
		public static let body5 = prtendard(family: .medium, size: 12)
		public static let caption1 = prtendard(family: .bold, size: 11)
		public static let caption2 = prtendard(family: .medium, size: 11)
	}
}

public extension MMMResource {
	static func registerFonts() {
		Font.Family.allCases.forEach {
			registerFont(bundle: Bundle.module, fontName: "Pretendard-\($0.rawValue)", fontExtension: "otf")
		}
	}
	
	fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
		guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
			  let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
			  let font = CGFont(fontDataProvider) else {
				  fatalError("Couldn't create font from data")
			  }
		
		var error: Unmanaged<CFError>?
		
		CTFontManagerRegisterGraphicsFont(font, &error)
	}
}

