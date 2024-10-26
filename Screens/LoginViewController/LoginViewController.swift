//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Nuke
import StreamChat
import UIKit

class LoginViewController: UIViewController, URLSessionTaskDelegate {
    @IBOutlet var configurationButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var onUserSelection: ((DemoUserType) -> Void)!
    var enteringLogin = false

    @IBOutlet weak var loginStack: UIStackView!
    @IBOutlet weak var phoneNumber: UISearchTextField!
    
    let users: [DemoUserType] = UserCredentials.builtInUsers.map { DemoUserType.credentials($0) }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.delegate = self
        tableView.dataSource = self

        tableView.tableFooterView = UIView()
        tableView.isHidden = true
        configurationButton.isHidden = true
        if #available(iOS 15.0, *) {
            configurationButton.configuration = .filled()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        if (!enteringLogin) {
            let trimmedString = phoneNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.present(alert, animated: true, completion: nil)
            let loginUserCredentials = UserCredentials(id: trimmedString, name: "name", avatarURL: URL(string: "https://bit.ly/2TIt8NR")!, token: .development(userId: trimmedString), birthLand: "birth")
            var loginUser: DemoUserType
            loginUser = DemoUserType.credentials(loginUserCredentials)
            onUserSelection(loginUser)
            NSLog(trimmedString)
            }
        } else {
            let alert = UIAlertController(title: "Enter Phone Number", message: "Please enter a phone number to login.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapConfigurationButton(_ sender: Any) {
        let configViewController = AppConfigViewController()
        let navController = UINavigationController(rootViewController: configViewController)
        present(navController, animated: true, completion: nil)
    }
}

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCredentialsCell", for: indexPath) as? UserCredentialsCell else { return UITableViewCell() }

        let user = users[indexPath.row]

        switch user {
        case let .credentials(userCredentials):
            Nuke.loadImage(with: userCredentials.avatarURL, into: cell.avatarView)
            cell.avatarView.backgroundColor = .clear
            cell.nameLabel.text = userCredentials.name
            cell.descriptionLabel.text = "Stream test user"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]

        switch user {
        case .credentials:
            onUserSelection(user)
        }
    }
}
