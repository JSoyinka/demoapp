//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatUI
import UIKit
import Contacts

final class DemoChatChannelListItemView: ChatChannelListItemView {
    private lazy var customUnreadView = UIView()

//    override var contentBackgroundColor: UIColor {
//        // In case it is a message search, we want to ignore the pinning behaviour.
//        if content?.searchResult?.message != nil {
////            return appearance.colorPalette.lightBorder
//            return super.contentBackgroundColor
//        }
//        if AppConfig.shared.demoAppConfig.isChannelPinningEnabled && content?.channel.isPinned == true {
////            return appearance.colorPalette.lightBorder
//            return appearance.colorPalette.pinnedMessageBackground
//        }
////        return appearance.colorPalette.lightBorder
//        return super.contentBackgroundColor
//    }
    
    
    // MARK: - App Logic
//    func showMessage(message: String) {
//        // Create an Alert
//        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
//
//        // Add an OK button to dismiss
//        let dismissAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) -> Void in
//        }
//        alertController.addAction(dismissAction)
//
//        // Show the Alert
//        cha.presentViewController(alertController, animated: true, completion: nil)
//    }

    //TODO handle denied
//    func requestForAccess(completionHandler: (_ accessGranted: Bool) -> Void) {
//        // Get authorization
//        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
//
//        // Find out what access level we have currently
//        switch authorizationStatus {
//        case .authorized:
//            completionHandler(true)
//
//        case .denied, .notDetermined:
//            CNContactStore().requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
//                if access {
//                    completionHandler(access)
//                }
//                else {
//                    if authorizationStatus == CNAuthorizationStatus.Denied {
//                        completionHandler(false)
////                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
////                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
////                            self.showMessage(message: message)
//                        })
//                    }
//                }
//        case .restricted:
//            
//        @unknown default:
//            <#code#>
//        })
//
//        default:
//            completionHandler(false)
//        }
//    }
    //TODO handle denied
    let store = CNContactStore()

    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
//            showSettingsAlert(completionHandler)
            NSLog("Failed")
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        NSLog("Failed")
                    }
                }
            }
        @unknown default:
            completionHandler(false)
        }
    }

    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "This app requires access to Contacts to proceed. Go to Settings to grant access.", preferredStyle: .alert)
        if
            let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
                alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                    completionHandler(false)
                    UIApplication.shared.open(settings)
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        })
//        present(alert, animated: true)
    }

//    func searchForContactUsingPhoneNumber(phoneNumber: String) {
//    }

    override func setUpLayout() {
        super.setUpLayout()
//        var spacingContainer = ContainerStackView()
//        spacingContainer.isLayoutMarginsRelativeArrangement = true
        let newView = UIView()
        newView.setContentHuggingPriority(UILayoutPriority(250 / 2.0), for: .horizontal)
        let newerView = UIView()
        NSLayoutConstraint.activate([newerView.heightAnchor.constraint(equalToConstant: 60)])
        NSLayoutConstraint.activate([newerView.widthAnchor.constraint(equalToConstant: 0)])
        mainContainer.replaceArrangedSubviews(with: [
            newerView,
            avatarView,
            rightContainer
        ])
        mainContainer.layer.borderWidth = 2.5
        mainContainer.layer.cornerRadius = 15
        mainContainer.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
        topContainer.replaceArrangedSubviews(with: [
            titleLabel, timestampLabel, newView, unreadCountView
        ])
//        NSLayoutConstraint.activate([
//            customUnreadView.widthAnchor.constraint(equalTo: customUnreadView.heightAnchor),
//            customUnreadView.widthAnchor.constraint(equalToConstant: 10),
//        ])

//        NSLayoutConstraint.activate([avatarView.heightAnchor.constraint(equalToConstant: 45)])

        
    }
    
    override func setUpAppearance() {
        super.setUpAppearance()
        titleLabel.font = appearance.fonts.subheadlineBold
//        customUnreadView.backgroundColor = tintColor
//        customUnreadView.layer.masksToBounds = true
//        customUnreadView.clipsToBounds = true
        
        avatarView.layer.shadowOpacity = 1.0
        avatarView.layer.shadowRadius = 5
        avatarView.layer.shadowColor = appearance.colorPalette.border.cgColor
        
//        if (unreadCountView.content != .noUnread) {
//            mainContainer.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
//            avatarView.layer.shadowColor = appearance.colorPalette.alert.cgColor
//        }
    }

    override func updateContent() {
        super.updateContent()
        var userNumber : CNPhoneNumber
        if ((titleLabel.text) != nil) {
            userNumber = CNPhoneNumber(stringValue: titleLabel.text!)
            do {
                let predicate = CNContact.predicateForContacts(matching: userNumber)
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey] as [CNKeyDescriptor]
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                if (contacts.count > 0) {
                    titleLabel.text = contacts[0].givenName + " " + contacts[0].familyName
                    if (contacts[0].imageData != nil) {
//                        NSLog(contacts[0].imageData)
//                       // there is an image for this contact
                        let newImage = UIImage(data: contacts[0].imageData!)
                        avatarView.presenceAvatarView.avatarView.imageView.image = newImage
                    }
                }
            } catch {
                NSLog("Failed to fetch contact, error: \(error)")
                // Handle the error.
            }

        }
        

//        userAvatarView.presenceAvatarView.onlineIndicatorView.isHidden = true
        if (content?.channel.extraData["is_cool"]?.boolValue != nil) {
            if (content!.channel.extraData["is_cool"]!.boolValue!) {
                titleLabel.text = "★ " + (titleLabel.text ?? "")
            }
        }
        if (content?.channel.unreadCount.messages != nil) {
            if (content!.channel.unreadCount.messages > 0) {
                mainContainer.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
                avatarView.layer.shadowColor = appearance.colorPalette.alert.cgColor
            }
        }
        if (content?.channel.unreadCount.messages != nil) {
            if (content!.channel.unreadCount.messages == 0) {
                mainContainer.backgroundColor = UIColor(white: 0.2, alpha: 0.4)
                avatarView.layer.shadowColor = appearance.colorPalette.border.cgColor
            }
        }


        backgroundColor = contentBackgroundColor
    }
}
