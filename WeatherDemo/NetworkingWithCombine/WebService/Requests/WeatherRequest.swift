//
//  WeatherRequest.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 23/05/21.
//

import Foundation
import Combine

struct WeatherRequest: RequestConvertable, KeyBasedRequest {
    
    typealias Response = Place
    typealias ResponseParser = GenericResponseParser<Place> //WeatherResponseParser
    
    var path: String = "data/2.5/weather"
    var method: String = "GET"
    var header: [String : String]?
    var parser: ResponseParser? //= GenericResponseParser<Place>() //WeatherResponseParser()
    var errorParser: ErrorParserType? = DefaultErrorParser()
    var query: String
    
    public init(query: String) {
        self.query = query
    }
    
    func parameter() -> [String : Any]? {
        ["q":query]
    }
}


struct WeatherResponseParser: ResponseParserType {

    typealias Response = Weather
    
    func parse(data: Data) -> Weather? {
        try? JSONDecoder().decode(Response.self, from: data)
    }
    
}
