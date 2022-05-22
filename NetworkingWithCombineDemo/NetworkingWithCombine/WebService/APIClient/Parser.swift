//
//  Parser.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 24/04/22.
//

import Foundation

struct GenericResponseParser<T: Decodable>: ResponseParserType {

    typealias Response = T
    
    func parse(data: Data) throws -> T  {
        try JSONDecoder().decode(Response.self, from: data)
    }
    
}

struct DefaultErrorParser: ErrorParserType {
    
     func parse(data: JSONDictionary) -> Error? {
        print("Error: \(data)")

        guard let message = data["message"] as? String else {
            return nil
        }

         return APIError.some(nil, message)
        
    }
}
