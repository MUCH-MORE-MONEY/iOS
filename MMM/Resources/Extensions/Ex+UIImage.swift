//
//  Ex+UIImage.swift
//  MMM
//
//  Created by Park Jungwoo on 2023/06/03.
//

import UIKit

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
	}

	/// Image 오른쪽에 Text를 붙여 UIImage를 만드는 기능
	func textEmbeded(text: String, font: UIFont, color: UIColor, spacing: CGFloat, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) -> UIImage {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		paragraphStyle.lineBreakMode = .byWordWrapping
		
		let attrs: [NSAttributedString.Key: Any] = [
			.font: font,
			.foregroundColor: color,
			.paragraphStyle: paragraphStyle
		]
		
		let expectedTextSize = (text as NSString).size(withAttributes: [.font: font])
		let width = leftMargin + expectedTextSize.width + self.size.width + spacing + rightMargin
		let height = max(expectedTextSize.height, self.size.width)
		let size: CGSize = CGSize(width: width, height: height)
		let rect = CGRect(x: leftMargin, y: (height - self.size.height) / 2, width: self.size.width, height: self.size.height)

		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		
		// Draw image
		self.draw(in: rect)

		// Draw text
		let textRect: CGRect = CGRect(x: leftMargin + self.size.width + spacing, y: 0, width: expectedTextSize.width, height: expectedTextSize.height)
		(text as NSString).draw(in: textRect.integral, withAttributes: attrs)

		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		// Render image as original
		return newImage.withRenderingMode(.alwaysOriginal)
	}
}
