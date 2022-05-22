//
//  AppContext.swift
//  NetworkingWithCombine
//
//  Created by Ankit on 16/05/21.
//

import Foundation

protocol DependencyType {
    var requestExecutor: RequestExecutor { get }
}

class AppContextDependencyContainer: DependencyType {
    
    public static let shared: AppContextDependencyContainer = AppContextDependencyContainer()
    
    lazy var requestExecutor: RequestExecutor = WebApiClient()
    
    private init() {}
}

protocol DependencyInjecting {
    var container: DependencyType { get }
}

extension DependencyInjecting {
    
    var container: DependencyType {
        DependencyInjector.dependencyContainer
    }
}

struct DependencyInjector: DependencyInjecting {
    static var dependencyContainer: DependencyType = AppContextDependencyContainer.shared
}


