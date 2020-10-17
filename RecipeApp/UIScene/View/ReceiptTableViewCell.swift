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

fileprivate extension RecipeTableViewCell {
    
    func setupViewProperties() {
        self.backgroundColor = .none
        self.selectionStyle = .none
        [recipeTitleLabel, recipeTypesLabel, recipeReadyTimeLabel].forEach {
            $0?.textColor = .white
        }
    }
}

extension RecipeTableViewCell {
    
    func configure(recipe: RecipeModel) {
        guard let imageUrl = recipe.image, let url = URL(string: imageUrl), let dishTypes = recipe.dishTypes, let readyInMinutes = recipe.readyInMinutes else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: imageUrl)
        let defaultImage = UIImage(named: "defaultImage")
        recipeImageView.kf.setImage(with: resource, placeholder: defaultImage)
        recipeTitleLabel.text = recipe.title
        let dishType = dishTypes.joined(separator: ", ")
        recipeTypesLabel.text = "Dish Type: " + dishType
        let stringMinutes = String(readyInMinutes)
        recipeReadyTimeLabel.text = "Ready In: " + stringMinutes + " Minutes"
    }
}
