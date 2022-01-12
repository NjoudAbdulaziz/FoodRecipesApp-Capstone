//
//  SignUpVC.swift
//  FoodRecipes
//
//  Created by Njoud Alrshidi on 05/05/1443 AH.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftMessages

class SignUpVC: UIViewController {
    
    //UIView Properties...
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var newEmailTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      }
    
    
    // MARK: - Sign up  Button ....
    
    @IBAction func register(_ sender: Any) {
        if userNameTF.text?.isEmpty == true || newEmailTF.text?.isEmpty == true || newPasswordTF.text?.isEmpty == true {
            
            let message: MessageView = MessageView.viewFromNib(layout: .cardView)
            message.configureTheme(.error)
            message.configureContent(body: "Please fill Name , Email and Password Fields !")
            var config = SwiftMessages.defaultConfig
            config.duration = .automatic
            config.presentationStyle = .top
            SwiftMessages.show(config: config, view: message)
            
            return
        }
        else {
            signUp()
           }
        }
    
    // MARK: - Auth  create new account .....
    
    func signUp() {
        
        Auth.auth().createUser(withEmail: newEmailTF.text ?? "" , password: newPasswordTF.text ?? "" ) { authResul, error in
            if let error = error {
                
                let message: MessageView = MessageView.viewFromNib(layout: .cardView)
                message.configureTheme(.error)
                message.configureContent(body: "Email address is alreaady use by another account!")
                var config = SwiftMessages.defaultConfig
                config.duration = .automatic
                config.presentationStyle = .top
                SwiftMessages.show(config: config, view: message)
                
                return
            }
            else {
                UserApi.addUser(name: self.userNameTF.text ?? "", uid: authResul?.user.uid ?? "" , email: self.newEmailTF.text ?? "" , completion: { check in
                            if check {
                                print("Done Saving in Database")
                
                                self.goToMainPage()
                            }
            })
            
            
                    }
            
        }
    }
    
    // MARK: - To Go To Main Page
    
    private func goToMainPage() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "main") as! MainVC
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
}


