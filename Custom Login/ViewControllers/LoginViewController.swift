//
//  LoginViewController.swift
//  Custom Login
//
//  Created by Steven Hertz on 12/30/19.
//  Copyright © 2019 DevelopItSolutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var errorLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupElements()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
    }

      func setupElements()  {
          
          /// Hide the error label
          errorLabel.alpha = 0
          
          /// Style the elements
          Utilities.styleTextField(firstNameTextField)
          Utilities.styleTextField(lastNameTextField)
          Utilities.styleFilledButton(loginButton)
          
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
