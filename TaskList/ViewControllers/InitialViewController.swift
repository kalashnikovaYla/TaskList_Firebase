//
//  InitialViewController.swift
//  TaskList
//
//  Created by sss on 11.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

final class InitialViewController: UIViewController {

    //MARK: Properties
    
    private var mainLabel: UILabel!
    private var warningLabel: UILabel!
    
    private var loginTextField: UITextField!
    private var passwordTextField: UITextField!
    
    private var enterButton: UIButton!
    private var createUserButton: UIButton!
    
    var databaseReference: DatabaseReference!
    
    
    //MARK: View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createLabels()
        createtextFields()
        createButtons()
        createConstraints()
        
        view.backgroundColor = UIColor(named: "purpleColor")
        loginTextField.text = ""
        passwordTextField.text = ""
        loginTextField.becomeFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Add stateDidChangeListener and present listTableViewController if user != nil
        databaseReference = Database.database().reference(withPath: "user")
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            
            if user != nil {
                let listTableViewController = ListTableViewController()
                self?.navigationController?.pushViewController(listTableViewController, animated: true)
            }
        }
    }
    
    
    //MARK: - Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    /// Create user
    @objc func createUserButtonTapped() {
        
        guard let email = loginTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if error != nil || user == nil {
                self?.displayWarningLabel()
            }
            guard let currentUser = user?.user.uid, let userEmail = user?.user.email else {return}
            let userReference = self?.databaseReference.child(currentUser)
            userReference?.setValue(["email": userEmail])
        }
        
    }
    
    /// Login
    @objc func enterButtonTapped() {
        
        guard let email = loginTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel()
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error != nil || user == nil {
                self?.displayWarningLabel()
            }
        }
    }
}


//MARK: Methods for create UI

extension InitialViewController {
    
    private func createLabels() {
        mainLabel = UILabel()
        mainLabel.text = "TASK LIST"
        mainLabel.font = UIFont(name: "Impact", size: 37.0)
        mainLabel.textColor = UIColor(named: "pinkColor")
        mainLabel.textAlignment = .center
        mainLabel.numberOfLines = 0
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainLabel)
        
        warningLabel = UILabel()
        warningLabel.text = "Некорректный логин или пароль"
        warningLabel.font = UIFont.systemFont(ofSize: 17)
        warningLabel.textColor = UIColor(named: "whiteColor")
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.alpha = 0
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningLabel)
    }
    
    private func createtextFields() {
        loginTextField = UITextField()
        loginTextField.textColor = UIColor(named: "purpleColor")
        loginTextField.backgroundColor = .secondarySystemBackground
        loginTextField.borderStyle = .roundedRect
        loginTextField.placeholder = "Электронная почта"
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        loginTextField.clearButtonMode = .whileEditing
        loginTextField.autocorrectionType = .no
        loginTextField.autocapitalizationType = .none
        view.addSubview(loginTextField)
        
        passwordTextField = UITextField()
        passwordTextField.textColor = UIColor(named: "purpleColor")
        passwordTextField.backgroundColor = .secondarySystemBackground
        passwordTextField.placeholder = "Пароль"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
    }
    
    private func createButtons() {
        createUserButton = UIButton()
        createUserButton.setTitle("Зарегистрироваться", for: .normal)
        createUserButton.setTitleColor(UIColor(named: "purpleColor"), for: .normal)
        createUserButton.backgroundColor = UIColor(named: "pinkColor")
        createUserButton.layer.cornerRadius = 20
        createUserButton.translatesAutoresizingMaskIntoConstraints = false
        createUserButton.addTarget(self, action: #selector(createUserButtonTapped), for: .touchUpInside)
        createUserButton.addTarget(self, action: #selector(createUserButtonTapped), for: .touchDown)
        view.addSubview(createUserButton)
        
        enterButton = UIButton()
        enterButton.setTitle("Войти", for: .normal)
        enterButton.setTitleColor(UIColor(named: "lightGrayColor"), for: .normal)
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        enterButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        view.addSubview(enterButton)
    }
    
    private func displayWarningLabel() {
        UIView.animate(withDuration: 3, delay: 0) { [weak self] in
            self?.warningLabel.alpha = 1
        } completion: { [weak self] _ in
            self?.warningLabel.alpha = 0
        }
    }
    
    //MARK: LayoutConstraint
    
    private func createConstraints() {
        
        NSLayoutConstraint.activate([
            
            mainLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height/6),
            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5),
            
            warningLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 15),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5),
            
            
            loginTextField.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: view.bounds.height/6),
            loginTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5),
            loginTextField.heightAnchor.constraint(equalToConstant: 35),
            
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 15),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 4/5),
            passwordTextField.heightAnchor.constraint(equalToConstant: 35),
            
            createUserButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: view.bounds.height/6),
            createUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createUserButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/5),
            createUserButton.heightAnchor.constraint(equalToConstant: 50),
            
            enterButton.topAnchor.constraint(equalTo: createUserButton.bottomAnchor, constant: 5),
            enterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/5),
            enterButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

}
