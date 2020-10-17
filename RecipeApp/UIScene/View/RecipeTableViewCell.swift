//
//  ReceiptTableViewCell.swift
//  RecipeApp
//
//  Created by Scott.L on 09/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import Kingfisher

class RecipeTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeTypesLabel: UILabel!
    @IBOutlet weak var recipeReadyTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewProperties()
    }
}

//MARK: -
//MARK: Setup Views

fileprivate extension RecipeTableViewCell {
    
    func setupViewProperties() {
        self.backgroundColor = .none
        self.selectionStyle = .none
        [recipeTitleLabel, recipeTypesLabel, recipeReadyTimeLabel].forEach {
            $0?.textColor = .white
        }
    }
}

//MARK: -
//MARK: Configure Data

extension RecipeTableViewCell {
    
    func configure(recipe: Recipe) {
        if let image = recipe.imageData {
            recipeImageView.image = UIImage(data: image)
        }
        else if let imageUrl = recipe.imageURL {
            if let url = URL(string: imageUrl) {
                let resource = ImageResource(downloadURL: url, cacheKey: imageUrl)
                                  let defaultImage = UIImage(named: "defaultImage")
                                  recipeImageView.kf.setImage(with: resource, placeholder: defaultImage)
            }
        }
        
        if let dishTypes = recipe.type {
            recipeTypesLabel.text = "Dish Type: " + dishTypes
        }
        let stringMinutes = String(recipe.time)
        recipeReadyTimeLabel.text = "Ready In: " + stringMinutes + " Minutes"
        recipeTitleLabel.text = recipe.title
        
        
        
    }
}
