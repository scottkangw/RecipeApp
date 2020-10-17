//
//  RecipeListViewController.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData

class RecipeListViewController: UIViewController {
    
    @IBOutlet private weak var recipeTypePickerView: UIPickerView!
    @IBOutlet private weak var tableView: UITableView!
    
    private let notFoundLabel = UILabel()
    private let viewModel = RecipeViewModel()
    private let authViewModel = FirebaseAuthViewModel()
    private var result: [Recipe]?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewProperties()
        bindModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
        tableView.reloadData()
    }

}

//MARK: -
//MARK: SetupView

fileprivate extension RecipeListViewController {
    
    func initiallyFetchData() {
        guard let _ = Defaults.isFirstRecipe else {
            Defaults.isFirstRecipe = true
            Defaults.synchronize()
            bindModel()
            return
        }
       
        let first = result?.first
        if let dishTypes = first?.type {
            recipeTypePickerView.selectRow(viewModel.compareRecipeType(dishTypes), inComponent: 0, animated: true)
        }
        tableView.reloadData()
    }
    
    func bindModel() {
        viewModel.fetchRecipeTypes()
        viewModel.recipeTypes.bind(to: recipeTypePickerView.rx.itemAttributedTitles) { _, model in
            return self.pickerAttributedText(model: model)
        }.disposed(by: disposeBag)
        
        recipeTypePickerView.rx.itemSelected.subscribe(onNext: { (row, value) in
            self.viewModel.coreDataResults.bindAndFire { [weak self] data in
                guard let self = self else { return }
                self.result?.removeAll()
                self.result = data.filter {
                    $0.type?.capitalized == self.viewModel.getRecipeType(row)
                }
                self.tableView.reloadData()
            }
        })
        .disposed(by: disposeBag)
    }
    
    func setupViewProperties() {
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Recipe"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddRecipe))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(handleSignOut))
        view.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: RecipeTableViewCell.self)
        tableView.backgroundColor = .none
    }
        
    func pickerAttributedText(model: RecipeType) -> NSAttributedString {
        let recipeTypes = "\(model.title.capitalized)"
        viewModel.getRandomRecipeFilter(by: recipeTypes, number: 8)
        viewModel.fetchData()
        viewModel.coreDataResults.bindAndFire { [weak self] data in
            guard let self = self else { return }
            self.result?.removeAll()
            self.result = data.filter {
                $0.type?.capitalized == recipeTypes
            }
            self.tableView.reloadData()
        }
        return NSAttributedString(string: recipeTypes,
                                  attributes: [
                                    NSAttributedString.Key.foregroundColor: UIColor.white,
                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)
                                  ])
    }
    
    func embedLabel(){
        tableView.separatorColor = nil
        self.notFoundLabel.isHidden = false
        notFoundLabel.textColor = .red
        notFoundLabel.text = "No recipe Found"
        notFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(notFoundLabel)
        notFoundLabel.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 50).isActive = true
        notFoundLabel.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor, constant: 0).isActive = true
    }
}

//MARK: -
//MARK: TableView Delegate & DataSource

extension RecipeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = result?.count else { return 0 }
        if count == 0 {
            embedLabel()
        } else {
            tableView.separatorColor = .gray
            notFoundLabel.isHidden = true
        }
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecipeTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        guard let recipeItem = result?[indexPath.row] else { return UITableViewCell() }
        cell.configure(recipe: recipeItem)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let recipeItem = result?[indexPath.row] else { return }
        let viewController = RecipeDetailsViewController(recipe: recipeItem)
        modalPresentationStyle = .overCurrentContext
        present(viewController, animated: true, completion: nil)
        viewController.completeEditing = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
}


//MARK: -
//MARK: Event Function
@objc fileprivate extension RecipeListViewController {
    func handleAddRecipe() {
        let addRecipeViewController = AddRecipeViewController()
        navigationController?.pushViewController(addRecipeViewController, animated: true)
    }
    
    func handleSignOut() {
        authViewModel.signOut()
        authViewModel.isSignOut = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            let viewController = SignUpViewController()
            viewController.modalPresentationStyle = .overCurrentContext
            self.present(viewController, animated: true, completion: nil)
        }
    }
}
    
