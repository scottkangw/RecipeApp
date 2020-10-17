//
//  RecipeViewModel.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//
import Alamofire
import Foundation
import RxSwift
import UIKit
import CoreData


final class RecipeViewModel {
    
    private let appServerClient: ApiServer
    private let disposeBag = DisposeBag()
    
    var coreDataResults = Bindable([Recipe]())
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let recipeTypes = PublishSubject<[RecipeType]>()
    var error: Error?

    init(appServerClient: ApiServer = ApiServer()) {
        self.appServerClient = appServerClient
    }
    
    func fetchRecipeTypes() {
        guard let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") else {
            return
        }
        let xml = RecipeTypeXML(contentsOf: path)
        DispatchQueue.main.async {
            self.recipeTypes.onNext(xml.recipeTypes)
        }
    }
    
    func compareRecipeType(_ dishType: String) -> Int {
        guard let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") else {
            return 0
        }
        let xml = RecipeTypeXML(contentsOf: path)
        var count = 0
        for i in xml.recipeTypes {
            if i.title.capitalized == dishType.capitalized {
                break
            }
            count += 1
        }
        return count
    }
    
    func getRecipeType(_ count: Int) -> String {
        guard let path = Bundle.main.url(forResource: "recipetypes", withExtension: "xml") else {
            return ""
        }
        let xml = RecipeTypeXML(contentsOf: path)
        return xml.recipeTypes[count].title.capitalized
    }
    
    func getRandomRecipeFilter(by name: String, number: Int = 8) {
        if coreDataResults.value.count <= 0 {
            appServerClient.fetchRandomRecipe(number: number).subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                data.forEach {
                    self.apiSaveToCoreData(newRecipe: $0)
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.error = error
            }).disposed(by: disposeBag)
        }
        self.fetchData()
    }
}

fileprivate extension RecipeViewModel {
    
}

//MARK: -
//MARK: CoreData

extension RecipeViewModel {
    
    func apiSaveToCoreData(newRecipe: RecipeModel?) -> Bool {
        guard let newRecipe = newRecipe else { return false }
        let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newEntry = Recipe(context: content)
        newEntry.title = newRecipe.title
        newEntry.imageURL = newRecipe.image
        newEntry.sourceURL = newRecipe.sourceURL
        newEntry.time = Int64(exactly: NSNumber(integerLiteral: newRecipe.readyInMinutes ?? 0)) ?? 0
        let dishType = newRecipe.dishTypes?.joined(separator: ", ")
        newEntry.type = dishType
        newRecipe.extendedIngredients?.forEach {
            let extendedIngredient = Ingredient(context: context)
            extendedIngredient.ingredient = $0.originalString
            extendedIngredient.recipe = newEntry
        }
        
        var count = 1
        newRecipe.analyzedInstructions?.forEach {
            $0.steps?.forEach {
                let instruction = Instruction(context: context)
                instruction.instruction = $0.step
                instruction.step = Int64(count)
                instruction.recipe = newEntry
                count += 1
            }
        }
        self.fetchData()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        return true
    }
    
    func saveToCoreData(newRecipe: RecipeModel?, imageData: Data) -> Bool {
        guard let newRecipe = newRecipe else { return false }
        let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newEntry = Recipe(context: content)
    
        newEntry.title = newRecipe.title
        newEntry.imageData = imageData
        newEntry.sourceURL = newRecipe.sourceURL
        newEntry.time = Int64(exactly: NSNumber(integerLiteral: newRecipe.readyInMinutes ?? 0)) ?? 0
        let dishType = newRecipe.dishTypes?.joined(separator: ", ")
        newEntry.type = dishType
        newRecipe.extendedIngredients?.forEach {
            let extendedIngredient = Ingredient(context: context)
            extendedIngredient.ingredient = $0.originalString
            extendedIngredient.recipe = newEntry
        }
        
        var count = 1
        newRecipe.analyzedInstructions?.forEach {
            let instruction = Instruction(context: context)
            instruction.instruction = $0.originalString
            instruction.recipe = newEntry
            instruction.step = Int64(count)
            count += 1
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        return true
    }
    
    func fetchData() {
        do {
            coreDataResults.value = try context.fetch(Recipe.fetchRequest())
        } catch {
            print("Couldn't Fetch Data")
        }
        
    }
    
    func updateData(updatedRecipe: RecipeModel, image: Data?, title: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let manageContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title as! CVarArg)
        clear(title: title)
        do {
            let test = try manageContext.fetch(fetchRequest)
            guard let objectUpdate = test[0] as? NSManagedObject else { return false }
            if let imageData = image {
                objectUpdate.setValue(imageData, forKey: "imageData")
            }
            objectUpdate.setValue(updatedRecipe.readyInMinutes, forKey: "time")
            objectUpdate.setValue(updatedRecipe.title, forKey: "title")
            objectUpdate.setValue(updatedRecipe.dishTypes?.first, forKey: "type")
            
            updatedRecipe.extendedIngredients?.forEach {
                let extendedIngredient = Ingredient(context: context)
                extendedIngredient.mutableSetValue(forKey: "ingredients")
                extendedIngredient.ingredient = $0.originalString
                extendedIngredient.recipe = objectUpdate as! Recipe
            }
            
            var count = 1
            updatedRecipe.analyzedInstructions?.forEach {
                let instruction = Instruction(context: context)
                instruction.instruction = $0.originalString
                instruction.step = Int64(count)
                instruction.recipe = objectUpdate as! Recipe
                count += 1
            }
            do {
                try manageContext.save()
            }
            catch {
                return false
            }
        }
        catch
        {
            return false
        }
        return true
    }
    
    func clear(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let manageContext = appDelegate.persistentContainer.viewContext
        var fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Recipe")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title as! CVarArg)
        do {
            let test = try manageContext.fetch(fetchRequest)
            guard let objectUpdate = test[0] as? NSManagedObject else { return }
            
            let recipe = objectUpdate as! Recipe
            if let ingredients = recipe.ingredients {
                for item in ingredients {
                    manageContext.delete(item as! NSManagedObject)
                }
            }
            
            if let instructions = recipe.instructions {
                for item in instructions {
                    manageContext.delete(item as! NSManagedObject)
                }
            }
            
            do {
                try manageContext.save()
            }
            catch {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
        
    }

}








