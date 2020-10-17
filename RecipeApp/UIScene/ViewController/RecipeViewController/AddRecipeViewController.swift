//
//  AddRecipeViewController.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet private weak var recipeTypePickerView: UIPickerView!
    @IBOutlet private weak var recipeImageView: UIImageView!
    @IBOutlet private weak var recipeTitleTextField: UITextField!
    @IBOutlet private weak var readyTimeTextField: UITextField!
    @IBOutlet private weak var ingredientTextField: UITextField!
    @IBOutlet private weak var ingredientTableView: UITableView!
    @IBOutlet private weak var instructionTextField: UITextView!
    @IBOutlet private weak var instructionTableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    
    private var imagePicker: ImagePicker?
    private var viewModel = RecipeViewModel()
    private let disposeBag = DisposeBag()
    private var recipeData: RecipeModel?
    private var ingredientData: [ExtendedIngredient]? = []
    private var instructionData: [AnalyzedInstruction]? = []
    private var recipeTypes: String = ""
    private var isEditMode: Bool = false
    private var existingRecipe: Recipe?
    private var selectedIngredientIndex: Int = 0
    private var isSelectedIngredientRow: Bool = false
    private var selectedInstructionIndex: Int = 0
    private var isSelectedInstructionRow: Bool = false
    var completed: (() -> ())?
    
    fileprivate enum ViewId: String {
        case cell = "cell"
    }
    
    convenience init(recipe: Recipe) {
        self.init()
        self.existingRecipe = recipe
        isEditMode = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewProperties()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let dishTypes = existingRecipe?.type {
            recipeTypePickerView.selectRow(viewModel.compareRecipeType(dishTypes), inComponent: 0, animated: true)

        }
    }
    
}

// MARK: -
// MARK: Setup View
extension AddRecipeViewController {
    
    func setupViewProperties() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectImage(tapGestureRecognizer:)))
        recipeImageView.isUserInteractionEnabled = true
        recipeImageView.addGestureRecognizer(tapGestureRecognizer)
        recipeImageView.image = UIImage(named: "selectImage")
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        [recipeTitleTextField, readyTimeTextField, ingredientTextField].forEach {
            $0?.delegate = self
            $0?.layer.borderColor = UIColor.black.cgColor
            $0?.layer.borderWidth = 1
        }
        addButton.addTarget(self, action: #selector(handleAddRecipe), for: .touchDown)
        instructionTextField.delegate = self
        instructionTextField.layer.borderColor = UIColor.black.cgColor
        instructionTextField.layer.borderWidth = 1
        [ingredientTableView, instructionTableView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.estimatedRowHeight = 85.0
            $0?.rowHeight = UITableView.automaticDimension
            $0?.register(UITableViewCell.self, forCellReuseIdentifier: ViewId.cell.rawValue)
        }
        if isEditMode == true {
            guard let recipe = existingRecipe else { return }
            configure(recipe)
        }
    }
    
    func bindViewModel() {
        viewModel.fetchRecipeTypes()
        viewModel.recipeTypes.bind(to: recipeTypePickerView.rx.itemAttributedTitles) { _, model in
            return self.pickerAttributedText(model: model)
        }.disposed(by: disposeBag)
        
        recipeTypePickerView.rx.itemSelected.subscribe(onNext: { (row, value) in
            self.recipeTypes = self.viewModel.getRecipeType(row)
        })

    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Validation", message: "Please Enter the Title and Ready In Minutes", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: -
// MARK: Setup Functionality
extension AddRecipeViewController {
    
    func configure(_ recipe: Recipe) {
        addButton.setTitle("Edit", for: .normal)
        
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
        
        if let ingredients = recipe.ingredients {
            ingredients.allObjects.forEach {
                let ingredient = ExtendedIngredient(originalString: ($0 as AnyObject).ingredient)
                ingredientData?.append(ingredient)
            }
        }
        
        if let instruction = recipe.instructions {
            instruction.allObjects.forEach {
                let instruction = AnalyzedInstruction(originalString: ($0 as AnyObject).instruction, steps: nil)
                instructionData?.append(instruction)
            }
        }
        
        recipeTitleTextField.text = recipe.title
        
        let time = recipe.time
        let stringMinutes = String(time)
        readyTimeTextField.text = stringMinutes
        
    }
    
    func pickerAttributedText(model: RecipeType) -> NSAttributedString {
        recipeTypes = "\(model.title.capitalized)"
        return NSAttributedString(string: recipeTypes,
                                  attributes: [
                                    NSAttributedString.Key.foregroundColor: UIColor.black,
                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
        ])
    }
    
    func editIngredientTableViewText(selectedRow: Int, text: String) {
        guard let _ = ingredientData?[selectedRow].originalString else { return }
        ingredientData?[selectedRow].originalString = text
        isSelectedIngredientRow = false
        ingredientTableView.reloadData()
    }
    
    func editInstructionTableViewText(selectedRow: Int, text: String) {
        guard let _ = instructionData?[selectedRow].originalString else { return }
        instructionData?[selectedRow].originalString = text
        isSelectedInstructionRow = false
        instructionTableView.reloadData()
    }
    
    func updateContent(newRecipe: RecipeModel, imageData: Data) {
        if isEditMode == true {
            guard let title = existingRecipe?.title else { return }
            if viewModel.updateData(updatedRecipe: newRecipe, image: imageData, title: title) == true {
                self.dismiss(animated: true, completion: nil)
                completed?()
            }
            else {
                presentAlert()
            }
        } else {
            if viewModel.saveToCoreData(newRecipe: recipeData, imageData: imageData) == true {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

// MARK: -
// MARK:  TextFieldDelegate and Image Picker
extension AddRecipeViewController: ImagePickerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    func didSelect(image: UIImage?) {
        self.recipeImageView.image = image
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == ingredientTextField {
            let ingredient = ExtendedIngredient(originalString: ingredientTextField.text)
            if isSelectedIngredientRow == true {
                editIngredientTableViewText(selectedRow: selectedIngredientIndex, text: ingredient.originalString ?? "")
            } else {
                ingredientData?.append(ingredient)
            }
            ingredientTextField.text = ""
            ingredientTableView.reloadData()
            return true
        }
        
        return false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == instructionTextField {
            let instructions = AnalyzedInstruction(originalString: instructionTextField.text, steps: nil)
            if isSelectedInstructionRow == true {
                editInstructionTableViewText(selectedRow: selectedInstructionIndex, text: instructions.originalString ?? "")
            } else {
                instructionData?.append(instructions)
            }
            instructionTextField.text = ""
            instructionTableView.reloadData()
            return true
        }
        return false
    }
}

//MARK: -
//MARK: TableView Delegate & DataSource
extension AddRecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.ingredientTableView {
            guard let count = ingredientData?.count else { return 0 }
            return count
        } else {
            guard let count = instructionData?.count else { return 0 }
            return count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewId.cell.rawValue) else {
            return UITableViewCell()
        }
        if tableView == self.ingredientTableView {
            guard let ingredients = ingredientData?[indexPath.row] else { return UITableViewCell() }
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont(name: "Segoe UI", size: 16)
            if let object = ingredients.originalString {
                cell.textLabel?.text = "\(indexPath.row + 1). \(object)"
            }
            return cell
        } else {
            guard let instructions = instructionData?[indexPath.row] else { return UITableViewCell() }
            cell.backgroundColor = .clear
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .black
            cell.textLabel?.font = UIFont(name: "Segoe UI", size: 16)
            if let object = instructions.originalString {
                cell.textLabel?.text = "Step: \(indexPath.row + 1). \(object)"
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.ingredientTableView {
            if editingStyle == .delete {
                self.ingredientData?.remove(at: indexPath.row)
                self.ingredientTableView.deleteRows(at: [indexPath], with: .automatic)
                self.isSelectedIngredientRow = false
                self.ingredientTableView.reloadData()
            }
        } else {
            if editingStyle == .delete {
                self.instructionData?.remove(at: indexPath.row)
                self.instructionTableView.deleteRows(at: [indexPath], with: .automatic)
                self.isSelectedInstructionRow = false
                self.instructionTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.ingredientTableView {
            guard let ingredients = ingredientData?[indexPath.row] else { return }
            ingredientTextField.text = ingredients.originalString
            isSelectedIngredientRow = true
            selectedIngredientIndex = indexPath.row
        } else {
            guard let instruction = instructionData?[indexPath.row] else { return }
            instructionTextField.text = instruction.originalString
            isSelectedInstructionRow = true
            selectedInstructionIndex = indexPath.row
        }
    }
}

// MARK: -
// MARK: Event Function
@objc fileprivate extension AddRecipeViewController {
    
    func handleAddRecipe() {
        var convertedTime: Int?
        if let time = readyTimeTextField.text {
            convertedTime = Int(time)
        }
        recipeData = RecipeModel(title: recipeTitleTextField.text, dishTypes: [recipeTypes], image: nil, readyInMinutes: convertedTime, sourceURL: nil, extendedIngredients: ingredientData, analyzedInstructions: instructionData, servings: nil)
        if let imageData = recipeImageView.image?.pngData() {
            if recipeData?.title == "", recipeData?.readyInMinutes == nil {
                presentAlert()
            }
            else {
                guard let newRecipe = recipeData else { return }
                updateContent(newRecipe: newRecipe, imageData: imageData)
            }
        }
    }
    
    func handleSelectImage(tapGestureRecognizer: UITapGestureRecognizer) {
        imagePicker?.present(from: self.view)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}


