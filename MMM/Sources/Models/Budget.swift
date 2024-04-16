//
//  Budget.swift
//  MMM
//
//  Created by geonhyeong on 3/27/24.
//

import Foundation

struct Budget: Codable, Equatable {
	let dateYM: String?
	let budget, estimatedEarning: Int?
}
