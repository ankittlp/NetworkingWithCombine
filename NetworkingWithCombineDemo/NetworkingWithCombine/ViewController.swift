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
        
        
        // Link two publishers to make continous search.
        // We want to show some actual error to user.
        let textChangePublisher = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.placeNameField).compactMap { notification in
            (notification.object as? UITextField)?.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main).flatMap({ Just($0)}).eraseToAnyPublisher()
        textChangePublisher.assign(to: \.searchText, on: self).store(in: &subscribers)
        
        searchTextPublisher?.sink(receiveCompletion: {_ in }, receiveValue: { [self] text in
            let request = WeatherRequest(query: text)
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
        }).store(in: &subscribers)
        
        
        
        // Single Pipeline
        // This an example where single pipeline is created but error is replced with placeholder `Place` object.
        
        /*
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self.placeNameField).compactMap { notification in
              (notification.object as? UITextField)?.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .flatMap { text -> Just<WeatherRequest> in
           var x = WeatherRequest(query: text)
           x.method = "GET"
            return Just(x)}
            .flatMap { city in
                return self.container.requestExecutor.executeRequest(request: city).catch { _ in
                    Just(Place(id: 0, name: "", coordinate: Coordinate.init(lat: 0, lon: 0), weatherValues: Weather.init(temp: nil, humidity: nil, pressure: nil))).map({$0})
                }
            }.sink { weather in
                print("Data -> \(weather)")
            }.store(in: &subscribers)

        
        */
        
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        
        let text = placeNameField.text ?? ""
        
        let request = WeatherRequest(query: text)
        
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
    }
    

}



