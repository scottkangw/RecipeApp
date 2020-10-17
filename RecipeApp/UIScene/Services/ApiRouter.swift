//
//  ApiRouter.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import Alamofire

protocol APIRouter: URLRequestConvertible {
    
    var baseURL: URL { get set}
    
    var path: String { get }
    
    var method: HTTPMethod { get }
    
    var parameters: [String: Any]? { get }
    
    var headers: [String: String]? { get }
    
}

extension APIRouter {
    
    var baseURL: URL {
        get {
            guard let rawBaseURL = URL(string: APIBasePath.url) else {
                fatalError(ApiError("Invalid url from components.").localizedDescription)
            }
            return rawBaseURL
        } set {
            self.baseURL = newValue
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String: String]? {
        return [:]
    }
    
    var parameters: [String: Any]? {
        return nil
    }
}

extension APIRouter {
    
    func asURLRequest() throws -> URLRequest {
        var method: HTTPMethod {
            return self.method
        }
        let params: ([String: Any]?) = {
            return self.parameters
        }()
        let url: URL = {
            guard let dataWithPath = self.baseURL.appendingPathComponent(self.path).absoluteString.removingPercentEncoding,
                let urlWithPath = URL(string: dataWithPath) else {
                return self.baseURL
            }
            return urlWithPath
        }()
        let encoding: ParameterEncoding = {
            return URLEncoding.default
        }()
        let headers: [String:String]? = {
            return self.headers
        }()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        return try encoding.encode(urlRequest, with: params)
    }
}



