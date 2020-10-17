//
//  RecipeModel.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation

import Foundation

struct RecipeType {
    var title: String
}

struct RecipeModel: Codable {
    var title : String?
    var dishTypes: [String]?
    var image: String?
    var readyInMinutes: Int?
    var sourceURL: String?
    var extendedIngredients: [ExtendedIngredient]?
    var analyzedInstructions: [AnalyzedInstruction]?
    var servings: Int?
}

struct RecipeResponse: Codable {
    var recipes: [RecipeModel]?
}

struct AutoCompleteSearchResponse: Codable {
    let id: Int
    let title: String
}

struct ExtendedIngredient: Codable {
    var originalString: String?
}

struct AnalyzedInstruction: Codable {
    var originalString: String?
    var steps: [Step]?
}

struct Step: Codable {
    var step: String?
}




