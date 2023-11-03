//
//  Ex+WidgetConfiguration.swift
//  MMMWidgetExtension
//
//  Created by geonhyeong on 11/3/23.
//

import Foundation
import SwiftUI

extension WidgetConfiguration {
	// iOS 17 부터 content margin
	func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
		if #available(iOSApplicationExtension 17.0, *) {
			return self.contentMarginsDisabled()
		} else {
			return self
		}
	}
}
