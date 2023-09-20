//
//  ServiceProviderProtocol.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/20.
//

import Foundation

protocol ServiceProviderProtocol: AnyObject {
	var statisticsProvider: StatisticsServiceProtocol { get }
	var profileProvider: ProfileServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
	static let shared = ServiceProvider()

	lazy var statisticsProvider: StatisticsServiceProtocol = StatisticsProvider()
	lazy var profileProvider: ProfileServiceProtocol = ProfileProvider()

	private init() { }
}
