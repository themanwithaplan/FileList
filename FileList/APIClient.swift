//
//  APIClient.swift
//  FileList
//
//  Created by Sharaf Nazaar on 1/9/21.
//

import Foundation

class APIClient {
    public var scheme: String = "https"
    public var host: String = "us-central1-mobile-developer-challenge.cloudfunctions.net"
    public var customEndPoint = "/listFiles"
    
    public var session = URLSession(configuration: .default)
    
    public init() {}
    
    public enum HTTPMethod: String {
        case get = "GET"
    }
    
    public func request(method: HTTPMethod, components: URLComponents, onComplete: @escaping (Result<Data?, RequestError>) -> Void) {
        
        guard let url = components.url else {
            onComplete(.failure(.init(message: "Could not create valid URL from components.")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let task = session.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                onComplete(.failure(.init(message: "Did not get an http response")))
                return
            }
            if let error = error as NSError? {
                onComplete(.failure(.init(message: "\(response.statusCode): \(error.localizedDescription)")))
                return
            }
            onComplete(.success(data))
        }
        task.resume()
    }
        
    public func get(path: String, queryItems: [URLQueryItem]? = nil, onComplete: @escaping (Result<Data?, RequestError>) -> Void) {
        var components = self.components(path: path)
        components.queryItems = queryItems
        request(method: .get, components: components, onComplete: onComplete)
    }
    
    func getFiles(completionHandler: @escaping (Files?, Error?) -> Void) {
        let serv = APIClient()
        serv.get(path: customEndPoint)
        { (response) in
            switch response {
            case .success(let data):
                guard let jsonData = data else {
                    return
                }
            do {
                let decoder = JSONDecoder()
                let filesData = try decoder.decode(Files.self, from: jsonData)
                completionHandler(filesData, nil)
            } catch {
                completionHandler(nil, nil)
            }
            case .failure( _):
                completionHandler(nil, nil)
            }
        }
    }

    
    func components(path: String) -> URLComponents {
        var components = URLComponents()
        components.host = self.host
        components.path = path
        components.scheme = scheme
        return components
    }
}

public struct RequestError: Error {
    public var message: String
}



