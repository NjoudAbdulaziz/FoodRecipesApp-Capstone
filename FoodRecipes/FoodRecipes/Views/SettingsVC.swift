//
//  SettingsVC.swift
//  FoodRecipes
//
//  Created by Njoud Alrshidi on 09/05/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase
class SettingsVC: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func signOutBtn(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
                  let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "firstPage") as! SignIn_SignUpVC
                  mainView.modalPresentationStyle = .fullScreen
                  self.present(mainView, animated: true, completion: nil)
                

        }
        catch let signOutError as NSError {
            print("Eroor logOut : %@" , signOutError)
        }
    }
}