//
//  ResponseData.swift
//  hhSwiftUI
//
//  Created by pavlovanv on 17.12.2024.
//

import Foundation

struct ResponseData: Decodable {
    let vacancyId: Int
    let title: String
    let salary: Int?
    let city: String
    let workExperience: String
}
