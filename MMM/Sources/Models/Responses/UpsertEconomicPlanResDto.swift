//
//  UpsertEconomicPlanResDto.swift
//  MMM
//
//  Created by yuraMacBookPro on 5/10/24.
//

import Foundation

struct UpsertEconomicPlanResDto: Codable {
    var data: Data
    var message: String
    var status: String
    
    struct Data: Codable {
        var economicPlanNo: String
    }
}
