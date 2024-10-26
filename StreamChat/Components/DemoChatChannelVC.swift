//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChatUI
import UIKit
import Contacts

final class DemoChatChannelVC: ChatChannelVC, UIGestureRecognizerDelegate {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        hidesBottomBarWhenPushed = true
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    channelAvatarView.presenceAvatarView.avatarView.imageView
    override func viewDidLoad() {
        super.viewDidLoad()
        var channelImage = UIImage(systemName: "person.crop.circle")
        
        overrideUserInterfaceStyle = .dark
        let avatarImage = UIBarButtonItem(
            image: channelImage,
            style: .plain,
            target: self,
            action: nil
        )

        let debugButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis")!,
            style: .plain,
            target: self,
            action: #selector(debugTap)
        )

        navigationItem.leftBarButtonItems = [avatarImage]
        
        // Custom back button to make sure swipe back gesture is not overridden.
        let customBackButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )

        navigationItem.setRightBarButtonItems([customBackButton, debugButton], animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }

    @objc private func debugTap() {
        guard let cid = channelController.cid else { return }

        let channelListVC: DemoChatChannelListVC
        if let mainVC = splitViewController?.viewControllers.first as? UINavigationController,
           let _channelListVC = mainVC.viewControllers.first as? DemoChatChannelListVC {
            channelListVC = _channelListVC
        } else if let _channelListVC = navigationController?.viewControllers.first as? DemoChatChannelListVC {
            channelListVC = _channelListVC
        } else {
            return
        }

        channelListVC.demoRouter?.didTapMoreButton(for: cid)
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
