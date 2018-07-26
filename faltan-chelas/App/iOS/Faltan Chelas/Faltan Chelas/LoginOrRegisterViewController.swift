//
//  LoginOrRegisterViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner

class LoginOrRegisterViewController: UIViewController {
    
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var TopClockBeerLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad();

        SwiftSpinner.hide();

        LoginButton.layer.cornerRadius = 18;
        RegisterButton.layer.cornerRadius = 18;
        RegisterButton.layer.borderWidth = 2;
        RegisterButton.layer.borderColor = UIColor.gray.cgColor;
    }
    
    @IBAction func LoginAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "LoginSegue", sender: self);
    }
    
    @IBAction func RegisterAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "RegisterSegue", sender: self);
    }
    
    @IBAction func ContactAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "ContactSegue", sender: self);
    }
    
    @IBAction func TermsAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "TermsSegue", sender: self);
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    
}
