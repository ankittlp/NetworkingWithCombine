//
//  ViewController.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 16/05/21.
//

import UIKit
import Combine

class ViewController: UIViewController, DependencyInjecting {

    var anyCancellable: AnyCancellable?
    var searchCancellable: AnyCancellable?
    var assignCancellable: AnyCancellable?
    
    var subscribers = Set<AnyCancellable>()
    
    var searchTextPublisher: PassthroughSubject<String,Error>? = PassthroughSubject()
    var searchText: String = "" {
        didSet{
            
            searchTextPublisher?.send(searchText)
        }
    }
    
    @IBOutlet weak var placeNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*anyCancellable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.placeNameField).compactMap { notification in
            (notification.object as? UITextField)?.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main).flatMap { [self] city in
            
            // This does not compile
            /*
            let request =  WeatherRequest(query: city)
            
            return (context.requestExecutor.executeRequest(request: request) ).catch { error in
                Just(Place(id: 0, name: "", coordinate: Coordinate.init(lat: 0, lon: 0), weatherValues: Weather.init(temp: nil, humidity: nil, pressure: nil)))
            }.map({ $0})*/
            
            // This works
            return (container.requestExecutor.executeRequest(request: WeatherRequest(query: city)) ).catch { error in
                Just(Place(id: 0, name: "", coordinate: Coordinate.init(lat: 0, lon: 0), weatherValues: Weather.init(temp: nil, humidity: nil, pressure: nil)))
            }.map({ $0})
        }.sink { object in
            print("Returned data - \(Thread.isMainThread ? "MainThred" : "Background  Thread")\(object)")
        }*/
        
        // This was a try for changing request to publisher
        //let x  = WeatherRequest(query: "").tryMap( { try $0.asURLRequest()})
        
//        flatMap({ city in
//                    let request = WeatherRequest(query: city)
//                return self.context.requestExecutor.executeRequest(request: request).catch { _ in
//                    Just(Place(id: 0, name: "", coordinate: Coordinate.init(lat: 0, lon: 0), weatherValues: Weather.init(temp: nil, humidity: nil, pressure: nil))).map($0)
//                }
//
//                })
        
        //Just(Place(id: 0, name: "", coordinate: Coordinate.init(lat: 0, lon: 0), weatherValues: Weather.init(temp: nil, humidity: nil, pressure: nil)))
        
        
        
        let textChangePublisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.placeNameField).compactMap { notification in
            (notification.object as? UITextField)?.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main).flatMap({ Just($0)}).eraseToAnyPublisher()
        
        
        
        textChangePublisher.assign(to: \.searchText, on: self).store(in: &subscribers)
        searchTextPublisher?.sink(receiveCompletion: {_ in }, receiveValue: { [self] text in
            let request = WeatherRequest(query: text)
            /*do {*/
                anyCancellable = container.requestExecutor.executeRequest(request: request).sink(receiveCompletion: { completion in
                    
                    print("Thread == \(Thread.current)")
                    switch completion {
                    case .finished:
                        print("receiveCompletion --> \(completion)")
                    case .failure(let error):
                        print("receiveCompletion \(error.localizedDescription)")
                    }
                }, receiveValue: { weather in
                    print("Data -> \(weather)")
                })
            /*} catch  {
                print("Error ->> \(error)")
            }*/
        }).store(in: &subscribers)
        
        
        
        // Single Pipeline - break after completion
        /*
       NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.placeNameField).compactMap { notification in
            (notification.object as? UITextField)?.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
       }.debounce(for: .milliseconds(500), scheduler: RunLoop.main).flatMap { text -> Just<WeatherRequest> in
           var x = WeatherRequest(query: text)
           x.method = "GET"
           return Just(x)
       }.map { request in
           return self.container.requestExecutor.executeRequest(request: request)
       }.flatMap({ $0}).sink { completion in
           
           print("Thread == \(Thread.current)")
           switch completion {
           case .finished:
               print("receiveCompletion --> \(completion)")
           case .failure(let error):
               print("receiveCompletion \(error.localizedDescription)")
           }
       } receiveValue: { weather in
           print("Data -> \(weather)")
       }.store(in: &subscribers)

        */
        
        
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        
        let text = placeNameField.text ?? ""
        
        let request = WeatherRequest(query: text)
        
        do {
            anyCancellable = try container.requestExecutor.executeRequest(request: request).sink(receiveCompletion: { completion in
                
                print("Thread == \(Thread.current)")
                switch completion {
                case .finished:
                    print("receiveCompletion --> \(completion)")
                case .failure(let error):
                    print("receiveCompletion \(error.localizedDescription)")
                }
            }, receiveValue: { weather in
                print("Data -> \(weather)")
            })
        } catch  {
            print("Error ->> \(error)")
        }
        
        
        
    }
    

}

