//
//  ApiClient.swift
//  WeatherDemo
//
//  Created by Ankit on 23/05/21.
//

import Foundation
import Combine

class WebApiClient: RequestExecutor {
    
    private var configuration: URLSessionConfiguration
    private var session: URLSession
    
    init(sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default) {
        configuration = URLSession.shared.configuration
    
        session = URLSession(configuration: configuration)
        
    }
    
    func executeRequest<R>(request: R)  -> AnyPublisher<R.Response, Error> where R : RequestConvertable {
        
        // This is to remove force try
        guard let requestt = try? request.asURLRequest()  else {
            return  Fail(error: APIError.badRequest()).eraseToAnyPublisher()
        }
        /*
         CurrentValueSubject<Void,Error>(()).tryMap { () in
             throw  APIError.badRequest()
         }
         */
        
        return session.dataTaskPublisher(for: /*try! request.asURLRequest()*/ requestt).print().tryMap({ [self] (data: Data, response: URLResponse) -> Data in
            if let httpResponse = response as? HTTPURLResponse {
                if request.reponseValidRange.contains(httpResponse.statusCode) {
                    return data
                }else {
                    throw parseError(data: data, response: response, errorParser: request.errorParser)
                }
            } else {
                throw APIError.invalidResponse()
            }
        }).tryMap { returnData in
            if let parser = request.parser {
                
                do {
                    if let object =  try parser.parse(data: returnData) {
                        return object
                    } else {
                        throw APIError.parseError()
                    }
                } catch {
                    throw APIError.parseError(error)
                }
                /*
                if  let object =  try parser.parse(data: returnData) {
                    return object
                }else {
                    throw APIError.parseError()
                }*/
            }else {
                if let Object = try? JSONDecoder().decode(R.Response.self, from: returnData) {
                    return Object
                }else {
                    throw APIError.parseError()
                }
            }
        }.mapError({ error in
            if let error = error as? APIError {
                return error
            } else {
                return APIError.unknown(error)  
            }
        }).receive(on: RunLoop.main).eraseToAnyPublisher()
        /*.map({ data in
            if let parser = request.parser {
                return parser.parse(data: data)
            }else {
                return JSONDecoder().decode(R.Response.self, from: data)
            }
        }).eraseToAnyPublisher()*/
        //.map({ (request.parser!.parse(data: $0))}).receive(on: RunLoop.main).eraseToAnyPublisher()
        //.decode(type: R.Response.self, decoder: JSONDecoder()).eraseToAnyPublisher()
            //.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    
    private
    func parseError(data: Data, response: URLResponse, errorParser: ErrorParserType?) -> Error {
        
        var errorToReturn: Error?
        
        if let httpUrlResponse = response as? HTTPURLResponse {
            
            if let errorParser = errorParser
            {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                    if let parsedError = errorParser.parse(data: json) {
                        errorToReturn = parsedError
                    }
                }
            }
            
            switch httpUrlResponse.statusCode {
            
            case 400:
                errorToReturn = APIError.badRequest(errorToReturn)
            case 401:
                errorToReturn = APIError.unAuthorised(errorToReturn)
            case 404:
                errorToReturn = APIError.notFound(errorToReturn)
            case 400...499:
                break
            case 500...599:
                errorToReturn = APIError.serverError()
            default:
                errorToReturn = APIError.unknown()
            }
        }
        
        return errorToReturn ?? APIError.invalidResponse()
    }
    
}
