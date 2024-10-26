//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatUI
import UIKit

final class DemoChatChannelListRouter: ChatChannelListRouter {
    enum ChannelPresentingStyle {
        case push
        case modally
        case embeddedInTabBar
    }

    var channelPresentingStyle: ChannelPresentingStyle = .push
    var onLogout: (() -> Void)?
    var onDisconnect: (() -> Void)?

    lazy var streamModalTransitioningDelegate = StreamModalTransitioningDelegate()

    func showCreateNewChannelFlow() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let chatViewController = storyboard.instantiateViewController(withIdentifier: "CreateChatViewController") as? CreateChatViewController {
            chatViewController.searchController = rootViewController.controller.client.userSearchController()
            rootNavigationController?.pushViewController(chatViewController, animated: true)
        }
    }

    override func showCurrentUserProfile() {
        rootViewController.presentUserOptionsAlert(
            onLogout: onLogout,
            onDisconnect: onDisconnect,
            client: rootViewController.controller.client
        )
    }

    override func showChannel(for cid: ChannelId) {
        switch channelPresentingStyle {
        case .push:
            super.showChannel(for: cid)

        case .modally:
            let vc = components.channelVC.init()
            vc.channelController = rootViewController.controller.client.channelController(for: cid)
            let navVc = UINavigationController(rootViewController: vc)
            navVc.transitioningDelegate = streamModalTransitioningDelegate
            navVc.modalPresentationStyle = .custom
            rootNavigationController?.present(navVc, animated: true, completion: nil)

        case .embeddedInTabBar:
            let vc = components.channelVC.init()
            vc.channelController = rootViewController.controller.client.channelController(for: cid)
            vc.tabBarItem = .init(title: "Chat", image: nil, tag: 0)

            let dummyViewController = UIViewController()
            dummyViewController.tabBarItem = .init(title: "Dummy", image: nil, tag: 1)

            let tabBarController = UITabBarController()
            tabBarController.view.backgroundColor = .systemBackground
            tabBarController.viewControllers = [vc, dummyViewController]
            // Make the tab bar not translucent to make sure the
            // keyboard handling works in all conditions.
            tabBarController.tabBar.isTranslucent = false

            rootNavigationController?.show(tabBarController, sender: self)
        }
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    override func didTapMoreButton(for cid: ChannelId) {
        let channelController = rootViewController.controller.client.channelController(for: cid)
        let canUpdateChannel = channelController.channel?.canUpdateChannel == true
        let canUpdateChannelMembers = channelController.channel?.canUpdateChannelMembers == true
        let canBanChannelMembers = channelController.channel?.canBanChannelMembers == true
        let canFreezeChannel = channelController.channel?.canFreezeChannel == true
        let canMuteChannel = channelController.channel?.canMuteChannel == true
        let canSetChannelCooldown = channelController.channel?.canSetChannelCooldown == true
        let canSendMessage = channelController.channel?.canSendMessage == true

        rootViewController.presentAlert(title: "Select an action", actions: [
            .init(title: "Update Name", isEnabled: canUpdateChannel, handler: { [unowned self] _ in
                self.rootViewController.presentAlert(title: "Enter channel name", textFieldPlaceholder: "Channel name") { name in
                    guard let name = name, !name.isEmpty else {
                        self.rootViewController.presentAlert(title: "Name is not valid")
                        return
                    }
                    channelController.updateChannel(
                        name: name,
                        imageURL: channelController.channel?.imageURL,
                        team: channelController.channel?.team
                    ) { [unowned self] error in
                        if let error = error {
                            self.rootViewController.presentAlert(
                                title: "Couldn't update name of channel \(cid)",
                                message: "\(error)"
                            )
                        }
                    }
                }
            }),
            .init(title: "Knot Thread", isEnabled: canUpdateChannel, handler: { _ in
                channelController.truncateChannel(hardDelete: false, systemMessage: "Thread Knotted") { [unowned self] error in
                    if let error = error {
                        self.rootViewController.presentAlert(
                            title: "Couldn't knot thread \(cid)",
                            message: "\(error.localizedDescription)"
                        )
                    }
                }
                channelController.partialChannelUpdate(extraData: ["is_cool": false]) { error in
                    if let error = error {
                        self.rootViewController.presentAlert(title: "Couldn't change channel \(cid)", message: "\(error)")
                    }
                }
            .init(title: "Enable Carte Blanche", isEnabled: canMuteChannel, handler: { [unowned self] _ in
                channelController.partialChannelUpdate(extraData: ["is_cool": true]) { error in
                    if let error = error {
                        self.rootViewController.presentAlert(title: "Couldn't change channel \(cid)", message: "\(error)")
                    }
                }
            }),
            .init(title: "Disable Carte Blanche", isEnabled: canMuteChannel, handler: { [unowned self] _ in
                channelController.partialChannelUpdate(extraData: ["is_cool": false]) { error in
                    if let error = error {
                        self.rootViewController.presentAlert(title: "Couldn't change channel \(cid)", message: "\(error)")
                    }
                }
                
            }),
            .init(title: "Delete channel", isEnabled: channelController.channel?.isHidden == false, handler: { [unowned self] _ in
                self.rootViewController.presentAlert(
                    title: "Clear History?",
                    message: nil,
                    actions: [
                        .init(title: "Clear History", handler: { _ in
                            channelController.hideChannel(clearHistory: true) { error in
                                if let error = error {
                                    self.rootViewController.presentAlert(
                                        title: "Couldn't hide channel \(cid)",
                                        message: "\(error)"
                                    )
                                }
                            }
                        }),
                        .init(title: "Keep History", handler: { _ in
                            channelController.hideChannel(clearHistory: false) { error in
                                if let error = error {
                                    self.rootViewController.presentAlert(
                                        title: "Couldn't hide channel \(cid)",
                                        message: "\(error)"
                                    )
                                }
                            }
                        })
                    ],
                    cancelHandler: nil
                )
            }),

    override func didTapDeleteButton(for cid: ChannelId) {
        rootViewController.controller.client.channelController(for: cid).deleteChannel { error in
            if let error = error {
                self.rootViewController.presentAlert(title: "Channel \(cid) couldn't be deleted", message: "\(error)")
            }
        }
    }
}

private extension UIAlertAction {
    convenience init(
        title: String?,
        isEnabled: Bool = true,
        style: Style = .default,
        handler: ((UIAlertAction) -> Void)?
    ) {
        self.init(
            title: title,
            style: style,
            handler: handler
        )
        self.isEnabled = isEnabled
    }
}
