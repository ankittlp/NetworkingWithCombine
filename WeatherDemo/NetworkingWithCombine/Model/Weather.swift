//
//  Weather.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 16/05/21.
//

import Foundation



struct Place: Decodable {
    let id: Int
    let name: String
    let coordinate: Coordinate
    let weatherValues: Weather?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case coordinate = "coord"
        case weatherValues = "main"
    }
    
    
}

struct Coordinate: Decodable {
    let lat: Double
    let lon: Double
}

struct Weather: Decodable {
    let temp: Double?
    let humidity: Double?
    let pressure: Double?
}
