//
//  ViewController.swift
//  Custom Login
//
//  Created by Steven Hertz on 12/30/19.
//  Copyright © 2019 DevelopItSolutions. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

public struct City: Codable {

    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }

}



class ViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        print("We are doing read!")
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("loginVerification").document("logins")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let record = document.data(), let emails = record["emails"] as? [String: String]
                    else {fatalError("could not convert it to a non optional")}
                if let email =  emails["hertzsteven@icloud.com"] {
                    print(email)
                } else {
                    print("email address is not found")
                }
                
                
                //                let uid = authResult!.user.uid
                //                var ref: DocumentReference? = nil
                
                
                // Add a new document in collection "cities"
                //                db.collection("users").document(uid).setData([
                //                    "firstName": firstName,
                //                    "last": lastName,
                //                    "uid": uid,
                //                    "apiKey": teacherAPIKey
                //                ]) { err in
                //                    if let err = err {
                //                        print("Error writing document: \(err)")
                //                    } else {
                //                        print("Document successfully written!")
                //                    }
                //                }
                
                
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
}

