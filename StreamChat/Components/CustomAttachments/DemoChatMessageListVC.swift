//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChatUI
import UIKit

class DemoChatMessageListVC: ChatMessageListVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! ChatMessageCell
        let messageContentView = cell.messageContentView as! CustomChatMessageContentView
        

        return cell
    }

}
