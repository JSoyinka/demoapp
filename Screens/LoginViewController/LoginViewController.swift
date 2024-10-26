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
//    TODO
//    let users: [DemoUserType] = UserCredentials.builtInUsers.map { DemoUserType.credentials($0) } + [.guest("guest"), .anonymous]

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tableView.delegate = self
        tableView.dataSource = self

        // An old trick to force the table view to hide empty lines
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
        //TODO Twilio Login
        if (!enteringLogin) {
            let trimmedString = phoneNumber.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if trimmedString.count != 10 {
                let alert = UIAlertController(title: "10 Digits Required", message: "Please enter a 10 digit number.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            } else if trimmedString == "‪1111111111" {
                tableView.isHidden = false
                configurationButton.isHidden = false
                loginStack.isHidden = true
            } else if trimmedString == "4159881965" {
                onUserSelection(users[0])
                NSLog("Roman")
            } else if trimmedString == "9176407778" {
                onUserSelection(users[1])
                NSLog("Duffy")
            } else if trimmedString == "9094722428" {
                onUserSelection(users[2])
                NSLog("JSoyinka")
            } else {
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
//        TODO
//        case .guest:
//            cell.nameLabel.text = "Guest user"
//            cell.descriptionLabel.text = "user id: guest"
//            cell.avatarView.image = UIImage(systemName: "person.fill")
//            cell.avatarView.backgroundColor = .clear
//        case .anonymous:
//            cell.nameLabel.text = "Anonymous user"
//            cell.descriptionLabel.text = ""
//            cell.avatarView.image = UIImage(systemName: "person")
//            cell.avatarView.backgroundColor = .clear
        }

        return cell
    }
    
    func getLoginInfo(userNumber: String) async {
        let url = URL(string: "http://www.test.com/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        struct PhoneNumber: Codable {

            let number: String
        }
        let phoneNumber = PhoneNumber(number: userNumber)
        guard let data = try? JSONEncoder().encode(phoneNumber) else {return}
        request.httpBody = data

        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]

        switch user {
        case .credentials:
            onUserSelection(user)
//        TODO
//        case .credentials, .anonymous:
//            onUserSelection(user)
//        case .guest:
//            presentAlert(title: "Input a user id", message: nil, textFieldPlaceholder: "guest") { [weak self] userId in
//                if let userId = userId, !userId.isEmpty {
//                    self?.onUserSelection(.guest(userId))
//                } else {
//                    self?.onUserSelection(.guest("guest"))
//                }
//            }
        }
    }
}
