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
    
    let db = Firestore.firestore()

    
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
        
        /// Create the user in firebase
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            guard error == nil else {
                self.showError(error: "Error Creating User \(error?.localizedDescription ?? "no value")"); return
             }
            
           
            let docRef = self.db.collection("loginVerification").document("logins")
            
            docRef.getDocument { (document, error) in
                
                /// handle the all the possible errors getting to the api Key
                
                /// - make sure the dicument exists if not it is a fatal error
                guard let document = document, document.exists else {
                    print("Document not found:"); return
                }
                
                /// - get the record dictionary  &  get the email field from the record dicionary which is also a dictionary (or map) in their lingo
                guard let record = document.data(), let emails = record["emails"] as? [String: String] else {
                    fatalError("Could not get the email field in the logins document")
                }
                
                /// - look for the value from the dictionary with the key of ""hertzsteven@icloud.com"
                guard let userEmail = authResult?.user.email, let organization =  emails[userEmail] else {
                    
                    print("email address: \(String(describing: authResult?.user.email)) is not found")
                    self.showError(error: "email address: \(String(describing: authResult?.user.email)) is not found")
                    
                    ///Delete the user
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
                    
                     return
                }
                
                /// -> Success! Now that the value is gotten you send e-mail verification and create Api Record for the user
                
                /// send verification e-mail
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    
                    guard error == nil else {
                        /// show the error
                        self.showError(error: "Error send e-mail verification \(error?.localizedDescription ?? "no value")")
                        ///Delete the user
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
                        return
                    }

                    /// -> Success!, email sent.  create Api Record for the user
                    guard let theUID = authResult?.user.uid else {fatalError("could not get the uid")}
                    self.createAPIRecordForUser(with: organization, uid: theUID)

                    /// log user off
                    try! Auth.auth().signOut()
                    
                    }
                }
                
            }
        
    }

        
        
//
//
//
//        /// Create the user in firebase
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let err = error {
//                self.showError(error: "Error Creating User \(err.localizedDescription)")
//            } else {
//                /// user created now store it
//                print("Creating the user")
//
//
//                /*
//                /// Delete the user
//                let user = authResult!.user
//
//                user.delete { error in
//                  if let error = error {
//                    // An error happened.
//                    self.showError(error: "Error deleting user \(error.localizedDescription)")
//                    print("error deleting user")
//                  } else {
//                    // Account deleted.
//                    print("Account deleted")
//                  }
//                }
//                */
//
//                /* Send e-mail confirmation
//                Auth.auth().currentUser?.sendEmailVerification { (error) in
//                    if let error = error {
//                        self.showError(error: "Error send e-mail verification \(error.localizedDescription)")
//                    } else {
//                        print("email sent")
//                    }
//
//                }
//                */
//
//               /*  Create the document
//                let db = Firestore.firestore()
//
//                let docRef = db.collection("apiKeys").document("ydeSchool")
//                docRef.getDocument { (document, error) in
//                    if let document = document, document.exists {
//                        guard let record = document.data(), let teacherAPIKey = record["teacherAPIKey"] as? String
//                        else {fatalError("could not convert it to a non optional")}
//
//                        let uid = authResult!.user.uid
//                        var ref: DocumentReference? = nil
//
//
//                        // Add a new document in collection "cities"
//                        db.collection("users").document(uid).setData([
//                            "firstName": firstName,
//                            "last": lastName,
//                            "uid": uid,
//                            "apiKey": teacherAPIKey
//                        ]) { err in
//                            if let err = err {
//                                print("Error writing document: \(err)")
//                            } else {
//                                print("Document successfully written!")
//                            }
//                        }
//
//
////                        ref = db.collection("users").addDocument(data: [
////                            "firstName": firstName,
////                            "last": lastName,
////                            "uid": uid,
////                            "apiKey": teacherAPIKey
////                        ]) { err in
////                            if let err = err {
////                                print("Error adding document: \(err)")
////                            } else {
////                                print("Document added with ID: \(ref!.documentID)")
////                            }
////                        }
//
//                    } else {
//                        print("Document does not exist")
//                    }
//                }
//                */
//
//            }
//        }
//
//
//        /// Transition to home screen
//
//    }
//
    
    func createAPIRecordForUser(with organization: String, uid: String)  {
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return  }

         
         let docRef = db.collection("apiKeys").document(organization)
         
         docRef.getDocument { (document, error) in
             
             /// handle the all the possible errors getting to the api Key
             
             /// - make sure the document exists if not it is a fatal error
             guard let document = document, document.exists else {
                 print("Document not found:"); return
             }
             
             guard let record = document.data(), let teacherAPIKey = record["teacherAPIKey"] as? String else {
                 fatalError("could not convert it to a non optional")
             }
             
             ///
//             guard let uid = Auth.auth().currentUser?.uid else {
//                 fatalError("Could not get the uid")
//             }
             
             
             /// Add the user api key
             let docRef = self.db.collection("users").document(uid)
             docRef.setData(["firstName": firstName, "last": lastName, "uid": uid, "apiKey": teacherAPIKey]) { error in
                 
                 guard error == nil else {
                     print("Error writing document: \(error?.localizedDescription)"); return
                 }
                 
                 print("Document successfully written!")
             }
         }
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
