//
//  LogInController.swift
//  DSSUserLogIn
//
//  Created by David Quispe Aruquipa on 08/08/22.
//

import UIKit
import ParseSwift

class LogInController: UIViewController {
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Username *"
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.placeholder = "Password *"
        textField.textAlignment = .center
        return textField
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Log in", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Back4App Log In"
        
        // Lays out the login form
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, passwordTextField, logInButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        let stackViewHeight = CGFloat(stackView.arrangedSubviews.count) * (44 + stackView.spacing) - stackView.spacing
        
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: stackViewHeight).isActive = true
        
        // Adds the method that will be called when the user taps the login button
        logInButton.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        
        // If the user is already logged in, we redirect them to the HomeController
        guard let user = User.current else { return }
        let homeController = HomeController()
        homeController.user = user
        
        navigationController?.pushViewController(homeController, animated: true)
    }
    
    /// Called when the user taps on the singInButton button
    @objc private func handleLogIn() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Shows an alert with the appropriate title and message.
            return showMessage(title: "Error", message: "Invalid credentials.")
        }
        
        logIn(with: username, password: password)
    }
    
    /// Logs in the user and presents the app's home screen (HomeController)
    /// - Parameters:
    ///   - username: User's username
    ///   - password: User's password
    private func logIn(with username: String, password: String) {
//        // Logs in the user synchronously, it throws a ParseError error if something happened.
//        // This should be executed in a background thread!
//        do {
//            let loggedInUser = try User.login(username: username, password: password)
//
//            // After the login success we send the user to the home screen
//            let homeController = HomeController()
//            homeController.user = loggedInUser
//
//            navigationController?.pushViewController(homeController, animated: true)
//        } catch let error as ParseError {
//            showMessage(title: "Error", message: "Failed to log in: \(error.message)")
//        } catch {
//            showMessage(title: "Error", message: "Failed to log in: \(error.localizedDescription)")
//        }
        
        // Logs in the user asynchronously
        User.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let loggedInUser):
                self?.usernameTextField.text = nil
                self?.passwordTextField.text = nil

                // After the login success we send the user to the home screen
                let homeController = HomeController()
                homeController.user = loggedInUser

                self?.navigationController?.pushViewController(homeController, animated: true)
            case .failure(let error):
                self?.showMessage(title: "Error", message: "Failed to log in: \(error.message)")
            }
        }
    }
}

extension UIViewController {
    
    /// Presents an alert with a title, a message and a back button.
    /// - Parameters:
    ///   - title: Title for the alert
    ///   - message: Shor message for the alert
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .cancel))
        
        present(alertController, animated: true)
    }
}
