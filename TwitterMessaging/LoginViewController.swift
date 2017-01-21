//
//  LoginViewController.swift
//  TwitterMessaging
//
//  Created by Truong Vo on 1/20/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Twitter's login button
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                print("Logged in as @\(unwrappedSession.userName)")
                self.dismiss(animated: true, completion: {
                    // Post 'LoginSuccess' notification
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LoginSuccess"), object: nil)
                })
            } else {
                print("LOGIN ERROR = \(error!.localizedDescription)")
            }
        }
        //logInButton.loginMethods = [.webBased]
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

