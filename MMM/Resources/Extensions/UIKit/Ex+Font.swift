//
//  Ex+Font.swift
//  MMM
//
//  Created by geonhyeong on 2023/03/27.
//  Copyright © 2023 Lab.M. All rights reserved.
//

import UIKit
import SwiftUI

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
		
		public static func prtendard(family: Family = .regular, size: CGFloat = 11) -> UIFont {
			return UIFont(name: "Pretendard-\(family.rawValue)", size: size)!
		}
		
		// TODO: - lineHeight
        // MARK: - h0
        /// Weight : semibold, Size : 36
 		public static let h0 = prtendard(family: .semibold, size: 36)
        // MARK: - h1
        /// Weight : bold, Size : 28
		public static let h1 = prtendard(family: .bold, size: 28)
        // MARK: - h2
        /// Weight : bold, Size : 24
		public static let h2 = prtendard(family: .bold, size: 24)
        // MARK: - h3
        /// Weight : regular, Size : 28
		public static let h3 = prtendard(family: .regular, size: 28)
        // MARK: - h4
        /// Weight : semibold, Size : 20
		public static let h4 = prtendard(family: .semibold, size: 20)
		// MARK: - h5
		/// Weight : bold, Size : 20
		public static let h5 = prtendard(family: .bold, size: 20)
        // MARK: - h6
        /// Weight : medium, Size : 20
        public static let h6 = prtendard(family: .medium, size: 20)
        // MARK: - title1
        /// Weight : bold, Size : 18
		public static let title1 = prtendard(family: .bold, size: 18)
        // MARK: - title2
        /// Weight : semibold, Size : 18
		public static let title2 = prtendard(family: .semibold, size: 18)
        // MARK: - title3
        /// Weight : bold, Size : 16
		public static let title3 = prtendard(family: .bold, size: 16)
        // MARK: - medium3
        /// Weight : medium, Size : 18
        public static let medium1 = prtendard(family: .medium, size: 18)
        // MARK: - body3
        /// Weight: regular, Size : 18
        public static let body0 = prtendard(family: .regular, size: 18)
        // MARK: - body1
        /// Weight : regular, Size : 16
		public static let body1 = prtendard(family: .regular, size: 16)
        // MARK: - body2
        /// Weight : bold, Size : 14
		public static let body2 = prtendard(family: .bold, size: 14)
        // MARK: - body3
        /// Weight : regular, Size : 14
		public static let body3 = prtendard(family: .regular, size: 14)
        // MARK: - body4
        /// Weight : bold, Size : 12
		public static let body4 = prtendard(family: .bold, size: 12)
        // MARK: - body5
        /// Weight : regular, Size : 12
		public static let body5 = prtendard(family: .regular, size: 12)
        // MARK: - caption1
        /// Weight : bold, Size : 11
		public static let caption1 = prtendard(family: .bold, size: 11)
        // MARK: - caption2
        /// Weight : regular, Size : 11
		public static let caption2 = prtendard(family: .regular, size: 11)
        // MARK: - regular20
        /// Weight : regular, Size : 20
        public static let regular20 = prtendard(family: .regular, size: 20)
        // MARK: - medium14
        /// Weight : medium, Size : 14
        public static let medium14 = prtendard(family: .medium, size: 14)
        // MARK: - medium16
        /// Weight : medium, Size : 16
        public static let medium16 = prtendard(family: .medium, size: 16)
	}
}

public extension MMMResource {
	static func registerFonts() {
		Font.Family.allCases.forEach {
			registerFont(bundle: Bundle.main, fontName: "Pretendard-\($0.rawValue)", fontExtension: "otf")
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

public extension UIFont {
    var suFont: Font {
        return Font(self)
    }
}
