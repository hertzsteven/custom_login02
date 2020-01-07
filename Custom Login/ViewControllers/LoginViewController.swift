//
//  LoginViewController.swift
//  Custom Login
//
//  Created by Steven Hertz on 12/30/19.
//  Copyright © 2019 DevelopItSolutions. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupElements()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        errorLabel.text = ""
        
        /// Validate fields
        if let error = validateTheFields() {
            showError(error: error)
            return
        }
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                print("failed in guard")
                return
        }
        
        
        print(email, password)
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            guard error == nil else {
                self.showError(error: "Error Logging In \(error?.localizedDescription ?? "no value")"); return
            }
            
            /// Determine if the user is e-mail verified
            guard let isEmailVerified = authDataResult?.user.isEmailVerified else {
                fatalError("Could not get the indidicator field if user is e-mail verified")
            }
            
            switch isEmailVerified {
            case true:
                print("is verified")
            case false:
                print("not verified")
                self.showError(error: "Please Verify the e-mail")
                /// log user off
                try! Auth.auth().signOut()
                return
            }
            
            /// -> Success! It is verified so lets get to work
            
            let db = Firestore.firestore()
            
            let uid = authDataResult!.user.uid
            let docRef = db.collection("users").document(uid)
            
            docRef.getDocument { (document, error) in
                
                guard let document = document, document.exists else {
                     print("Document not found:"); return
                 }

                guard let record = document.data(), let apiKey = record["apiKey"] as? String else {
                    fatalError("could not convert it to a non optional")
                }
                
                /// -> Success! - got the document and now can retreive the information
                print("We got the apikey it is \(apiKey)")
                
            }
        }
    }
    
    
    func showError(error: String)  {
        errorLabel.text = error
        errorLabel.isHidden = false
    }
    
    
    func setupElements()  {
        
        /// Hide the error label
        errorLabel.alpha = 1
        errorLabel.isHidden = true
        
        /// Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    func validateTheFields() -> String? {
        
        if  emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
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
    
}
