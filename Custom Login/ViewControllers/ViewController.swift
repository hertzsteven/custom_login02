//
//  ViewController.swift
//  Custom Login
//
//  Created by Steven Hertz on 12/30/19.
//  Copyright © 2019 DevelopItSolutions. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Auth.auth().signIn(withEmail: "hertzsteven@icloud.com", password: "test1234@") { (authDataResult, error) in
//            if let error = error {
//                print("signin error", error.localizedDescription)
//            } else {
//                print("Getting the user")
//                switch authDataResult?.user.isEmailVerified {
//                case true:
//                    print("is verified")
//                case false:
//                    print("not verified")
//                default:
//                    print("in default")
//                }
//            }
//        }

        setupElements()
    }
    
    func setupElements()  {
        /// Style elements
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    @IBAction func updatePressed(_ sender: Any) {
        print("We are doing update!")
        
        let db = Firestore.firestore()
        
        // Update one field, creating the document if it does not exist.
        db.collection("apiKeys").document("ydeSchool").setData([ "capital": true, "arrayExample": [5, true, "hello"], ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
        
    @IBAction func readPressed(_ sender: Any) {
        
        let docRef = db.collection("loginVerification").document("logins")
        
        docRef.getDocument { (document, error) in
            
            /// handle the all the possible errors getting to the api Key
            
            /// - make sure the dicument exists if not it is a fatal error
            guard let document = document, document.exists else {
                print("Document not found:"); return
            }
            
            /// - get the record dictionary  &  get the email field from the record dicionary which is also a dictionary (or map) in their lingo
            guard let record = document.data(), let emails = record["emails"] as? [String: String] else {                //                /*
                fatalError("Could not get the email field in the logins document")
            }
            
            /// - look for the value from the dictionary with the key of ""hertzsteven@icloud.com"
            guard let organization =  emails["hertzsteven@icloud.com"] else {
                print("email address is not found"); return
            }
            
            /// - Now that the value is gottenyou could create Api Record for the user
            self.createAPIRecordForUser(with: organization)
            
        }
    }
    
    func createAPIRecordForUser(with organization: String)  {
        
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
            guard let uid = Auth.auth().currentUser?.uid else {
                fatalError("Could not get the uid")
            }
            
            
            /// Add the user api key
            let docRef = self.db.collection("users").document(uid)
            docRef.setData(["firstName": "Sam", "last": "Smith", "uid": uid, "apiKey": teacherAPIKey]) { error in
                
                guard error == nil else {
                    print("Error writing document: \(error?.localizedDescription)"); return
                }
                
                print("Document successfully written!")
            }
        }
    }
    
}

