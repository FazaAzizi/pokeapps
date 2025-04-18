//
//  NetworkManager.swift
//  CodingTest
//
//  Created by Faza Azizi on 14/04/25.
//

import Foundation
import Network
import RxSwift
import RxCocoa
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    let isConnected = BehaviorRelay<Bool>(value: true)
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected.accept(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    func request<T: Decodable>(_ urlString: String, method: HTTPMethod = .get, parameters: Parameters? = nil) -> Observable<T> {
        return Observable.create { observer in
            // Check network connectivity first
            if !self.isConnected.value {
                observer.onError(NetworkError.noConnection)
                return Disposables.create()
            }
            
            let request = AF.request(urlString, method: method, parameters: parameters)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(NetworkError.afError(error))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        .observe(on: MainScheduler.instance)
    }
    
    func cancelAllRequests() {
        AF.session.getAllTasks { tasks in
            tasks.forEach { task in
                task.cancel()
            }
        }
    }
}

enum NetworkError: Error {
    case noConnection
    case invalidURL
    case invalidResponse
    case afError(Error)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection available"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .afError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
