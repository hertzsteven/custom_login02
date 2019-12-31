//
//  SignUpViewController.swift
//  Custom Login
//
//  Created by Steven Hertz on 12/30/19.
//  Copyright © 2019 DevelopItSolutions. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupElements()
        
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        errorLabel.text = ""
        
        /// Validate fields
        if let error = validateTheFields() {
            showError(error: error)
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let err = error {
                self.showError(error: "Error Creating User")
            } else {
                /// user created now store it
                
            }
        }
        
        /// Create User
        
        
        /// Transition to home screen
        
    }
    
    func showError(error: String)  {
        errorLabel.text = error
        errorLabel.isHidden = false
    }
    
    func setupElements()  {
        
        /// Hide the error label
        errorLabel.isHidden = true
        
        /// Style the elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    func validateTheFields() -> String? {
        
        if firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Please fill out all fields")
            return "Please fill out all the fields"
        }
        
        if Utilities.isPasswordValid(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) == false {
            print("Please make sure your password is at least 8 chrachters, contains a special charachter and a number")
            return " Please make sure your password is at least 8 chrachters, contains a special charachter and a number"
        }
        
        return nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
