//
//  SignUpViewController.swift
//  RecipeApp
//
//  Created by Scott.L on 16/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    private var viewModel = FirebaseAuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewProperties()
    }
    
}

// MARK: -
// MARK: Setup View
private extension SignUpViewController {
    
    func setupViewProperties() {
        containerView.layer.cornerRadius = 25
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1
        self.hideKeyboardWhenTappedAround()
        actionButton.addTarget(self, action: #selector(signInTapped), for: .touchDown)
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Validation", message: "Please Enter the Email and Password", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmationAlert() {
        let alert = UIAlertController(title: "Create Account", message: "Account Not Found, Would you like to create an Account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: {_ in
            guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
                self.presentAlert()
                return
            }
            self.viewModel.signUp(email: email, password: password)
            self.viewModel.isSuccessful = { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
                let viewController = UINavigationController(rootViewController: RecipeListViewController())
                viewController.modalPresentationStyle = .overCurrentContext
                self.present(viewController, animated: true, completion: nil)
            }
            self.viewModel.isFailed = { [weak self] in
                guard let self = self else { return }
                self.presentAlert()
            }
        }
        ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: -
// MARK: Event Function
@objc fileprivate extension SignUpViewController {
    
    func signInTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            presentAlert()
            return
        }
        self.viewModel.signIn(email: email, password: password)
        self.viewModel.isSuccessful = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            let viewController = UINavigationController(rootViewController: RecipeListViewController())
            viewController.modalPresentationStyle = .overCurrentContext
            self.present(viewController, animated: true, completion: nil)
        }
        self.viewModel.isFailed = { [weak self] in
            guard let self = self else { return }
            self.presentAlert()
        }
        self.viewModel.checkSignUp = { [weak self] in
            guard let self = self else { return }
            self.confirmationAlert()
        }
        
        
    }
}


