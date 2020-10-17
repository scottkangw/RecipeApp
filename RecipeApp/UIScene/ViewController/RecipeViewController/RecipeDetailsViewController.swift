//
//  RecipeDetailsViewController.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import Kingfisher

class RecipeDetailsViewController: UIViewController {
    @IBOutlet private weak var recipeImageView: UIImageView!
    @IBOutlet private weak var recipeNameLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var ingredientTableView: ContentSizedTableView!
    @IBOutlet private weak var instructionTableView: ContentSizedTableView!
    @IBOutlet private weak var editButton: UIButton!
    
    fileprivate enum ViewId: String {
        case cell = "cell"
    }
    
    var recipe: Recipe?
    var instructionArray: [Instruction] = []
    var completeEditing: (()->())?
    
    init(recipe: Recipe) {
        super.init(nibName: nil, bundle: nil)
        self.recipe = recipe
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupViewProperties()
    }
    
}

//MARK: -
//MARK: Setup View

extension RecipeDetailsViewController {
    
    func setupViewProperties() {
        [ingredientTableView,instructionTableView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.estimatedRowHeight = 85.0
            $0?.rowHeight = UITableView.automaticDimension
            $0?.register(UITableViewCell.self, forCellReuseIdentifier: ViewId.cell.rawValue)
        }
        
        editButton.addTarget(self, action: #selector(handleContentEdit), for: .touchDown)
    }
    
    func configure() {
        if let image = recipe?.imageData {
            recipeImageView.image = UIImage(data: image)
        }
        
        else if let imageUrl = recipe?.imageURL {
            if let url = URL(string: imageUrl) {
                let resource = ImageResource(downloadURL: url, cacheKey: imageUrl)
                let defaultImage = UIImage(named: "defaultImage")
                recipeImageView.kf.setImage(with: resource, placeholder: defaultImage)
            }
        }
        
        if let dishTypes = recipe?.type {
            typeLabel.text = "Dish Type: " + dishTypes
        }
        
        recipeNameLabel.text = title
        
        if let time = recipe?.time {
            let stringMinutes = String(time)
            timeLabel.text = "Ready In: " + stringMinutes + " Minutes"
        }
        
        if let instructions = self.recipe?.instructions?.allObjects {
            instructions.forEach {
                let instruction = $0 as! Instruction
                instructionArray.append(instruction)
            }
            instructionArray.sort(by:{ $0.step < $1.step })
        }
        
        
    }
}

//MARK: -
//MARK: Event Function
@objc fileprivate extension RecipeDetailsViewController {
    
    func handleContentEdit() {
        guard let recipeSelected = recipe else { return }
        let modifyRecipeViewController = AddRecipeViewController(recipe: recipeSelected)
        self.present(modifyRecipeViewController, animated: true, completion: nil)
        
        modifyRecipeViewController.completed = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            self.completeEditing?()
        }
    }
}

//MARK: -
//MARK: TableView Delegate & DataSource

extension RecipeDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.ingredientTableView {
            guard let count = recipe?.ingredients?.count else { return 0 }
            return count
        } else {
            guard let count = recipe?.instructions?.count else { return 0 }
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewId.cell.rawValue) else {
            return UITableViewCell()
        }
        
        if tableView == self.ingredientTableView {
            guard let ingredients = recipe?.ingredients else { return UITableViewCell() }
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont(name: "Segoe UI", size: 16)
            if let object = ingredients.allObjects[indexPath.row] as? Ingredient {
                guard let ingredient = object.ingredient else { return UITableViewCell() }
                cell.textLabel?.text = "\(indexPath.row + 1). \(ingredient)"
            }
            return cell
        } else {
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont(name: "Segoe UI", size: 16)
            let object = instructionArray[indexPath.row]
                guard let instruction = object.instruction else {
                    return UITableViewCell() }
                
                cell.textLabel?.text = "Step \(object.step). \(instruction)"
            }
            return cell
        }
    
}


