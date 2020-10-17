//
//  ApiClient.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation

class APIBasePath {
    static var url = "https://api.spoonacular.com/"
}

class AppConfig {
    // 0fc27c7258ca46729dc741fd1205c85b
    // fe18736046d74c5294f21ad7da075a0d
    static let spoonacularKey = "0fc27c7258ca46729dc741fd1205c85b"
}

enum APIClient: APIRouter {
    
    case randomRecipe(number: Int)
    case autoCompleteRecipe(query: String)
    case categories
    
    var path: String {
        switch self {
        case .randomRecipe:
            return "/recipes/random"
        case .autoCompleteRecipe:
            return "/recipes/autocomplete"
        case .categories:
            return "A0CgArX3"
        }
    }
    
    var parameters: [String : Any]? {
        let key = AppConfig.spoonacularKey
        switch self {
        case .randomRecipe(let number):
            return ["apiKey": key,
                    "number": number]
        case .autoCompleteRecipe(let query):
            return ["apiKey": key,
                    "number": 8,
                    "query": query]
        case .categories:
            return nil
        }
    }
    
}
