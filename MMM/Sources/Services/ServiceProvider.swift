//
//  ServiceProvider.swift
//  MMM
//
//  Created by geonhyeong on 2023/09/20.
//

import Foundation

protocol ServiceProviderProtocol: AnyObject {
	var categoryProvider: CategoryServiceProtocol { get }
	var statisticsProvider: StatisticsServiceProtocol { get }
	var profileProvider: ProfileServiceProtocol { get }
    var detailProvider: DetailServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
	static let shared = ServiceProvider()

	lazy var categoryProvider: CategoryServiceProtocol = CategoryProvider()
	lazy var statisticsProvider: StatisticsServiceProtocol = StatisticsProvider()
	lazy var profileProvider: ProfileServiceProtocol = ProfileProvider()
    lazy var detailProvider: DetailServiceProtocol = DetailProvider()
    
	private init() { }
}
