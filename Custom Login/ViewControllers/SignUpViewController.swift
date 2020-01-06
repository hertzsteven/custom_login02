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
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let err = error {
                self.showError(error: "Error Creating User \(err.localizedDescription)")
            } else {
                /// user created now store it
                print("Creating the user")
                
                let user = authResult!.user

                user.delete { error in
                  if let error = error {
                    // An error happened.
                    self.showError(error: "Error deleting user \(error.localizedDescription)")
                    print("error deleting user")
                  } else {
                    // Account deleted.
                    print("Account deleted")
                  }
                }
                
                /* Send e-mail confirmation
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if let error = error {
                        self.showError(error: "Error send e-mail verification \(error.localizedDescription)")
                    } else {
                        print("email sent")
                    }
                    
                }
                */

               /*  Create the document
                let db = Firestore.firestore()
                
                let docRef = db.collection("apiKeys").document("ydeSchool")
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        guard let record = document.data(), let teacherAPIKey = record["teacherAPIKey"] as? String
                        else {fatalError("could not convert it to a non optional")}
                        
                        let uid = authResult!.user.uid
                        var ref: DocumentReference? = nil
                        
                        
                        // Add a new document in collection "cities"
                        db.collection("users").document(uid).setData([
                            "firstName": firstName,
                            "last": lastName,
                            "uid": uid,
                            "apiKey": teacherAPIKey
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                    
                        
//                        ref = db.collection("users").addDocument(data: [
//                            "firstName": firstName,
//                            "last": lastName,
//                            "uid": uid,
//                            "apiKey": teacherAPIKey
//                        ]) { err in
//                            if let err = err {
//                                print("Error adding document: \(err)")
//                            } else {
//                                print("Document added with ID: \(ref!.documentID)")
//                            }
//                        }

                    } else {
                        print("Document does not exist")
                    }
                }
                */
                
            }
        }
        
        
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
    

}
