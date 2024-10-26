//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatUI
import UIKit

extension ChatMessageLayoutOption {
    static let assistantMessage: Self = "assistantMessage"
    static let summaryMessage: Self = "summaryMessage"
}


final class CustomMessageOptionsResolver: ChatMessageLayoutOptionsResolver {
    override func optionsForMessage(
        at indexPath: IndexPath,
        in channel: ChatChannel,
        with messages: AnyRandomAccessCollection<ChatMessage>,
        appearance: Appearance
    ) -> ChatMessageLayoutOptions {
        // Call super to get the default options.
        var options = super.optionsForMessage(at: indexPath, in: channel, with: messages, appearance: appearance)
        // Remove all the options that we don't want to support.
        // By removing `.flipped` option, all messages will be rendered in the leading side.
        options.remove([.authorName, .deliveryStatusIndicator, .avatarSizePadding, .avatar, .reactions])

        // Insert the options that we want to support.
        options.insert([.timestamp])
        
        let messageIndex = messages.index(messages.startIndex, offsetBy: indexPath.item)
        let message = messages[messageIndex]
        if (message.extraData["is_AI"]?.boolValue != nil) {
            if (message.extraData["is_AI"]!.boolValue!) {
                options.insert([.assistantMessage])
            }
        }
        if (message.extraData["is_summary"]?.boolValue != nil) {
            if (message.extraData["is_summary"]!.boolValue!) {
                options.insert([.summaryMessage])
            }
        }

        return options
    }
}





