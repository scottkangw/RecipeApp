//
//  ApiServer.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
// MARK: Recipe
class ApiServer  {}

extension ApiServer {
    
    func fetchRandomRecipe(number: Int = 5) -> Observable<[RecipeModel]> {
        return Observable<[RecipeModel]>.create { observer -> Disposable in
            let request = AF.request(APIClient.randomRecipe(number: number))
            request.responseDecodable(of: RecipeResponse.self) { (response) in
                if let error = response.error {
                    observer.onError(error)
                    return
                }
                guard let recipes = response.value?.recipes else {
                    observer.onNext([])
                    return
                }
                observer.onNext(recipes)
            }
            return Disposables.create()
        }

    }

}
