//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import StreamChat
import StreamChatUI
import UIKit

final class CustomChatMessageContentView: ChatMessageContentView {
    override var maxContentWidthMultiplier: CGFloat { 1 }
    var oldText = ""
    var newText = ""
    var isShowingOldText = true
    var changeView: (() -> Void)?

    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        NSLog("OldText: " + String(oldText))
        NSLog("New Text: " + String(newText))
        if isShowingOldText {
            NSLog(String(isShowingOldText))
            textView?.text = newText + "..."
            NSLog("Pause.")
            isShowingOldText = !isShowingOldText
            NSLog(String(isShowingOldText))
        } else {
            NSLog(String(isShowingOldText))
            textView?.text = oldText
            isShowingOldText = !isShowingOldText
            NSLog("Pause.")
            NSLog(String(isShowingOldText))
        }
    }

    override func layout(options: ChatMessageLayoutOptions) {
        super.layout(options: options)

        // To have the avatarView aligned at the top with rest of the elements,
        // we'll need to set the `mainContainer` alignment to leading.
//        mainContainer.alignment = .leading
        if (options.contains(.assistantMessage) && !options.contains(.summaryMessage)) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            mainContainer.isUserInteractionEnabled = true
            mainContainer.addGestureRecognizer(tapGesture)
        }
        // Set inset to zero to align it with the message author
//        textView?.textContainerInset = .zero

        // Reverse the order of the views in the `bubbleThreadMetaContainer`.
        // This will reverse the order of the `textView` and `metadataContainer`
        let subviews = bubbleThreadFootnoteContainer.subviews
        bubbleThreadFootnoteContainer.removeAllArrangedSubviews()
        bubbleThreadFootnoteContainer.addArrangedSubviews(subviews.reversed())

        // We need to disable the layout margins of the text view
//        bubbleContentContainer.addArrangedSubviews([subviews.reversed()[0]])

//        bubbleContentContainer.alignment = .fill
    }
    
    override func updateContent() {
        super.updateContent()
        if (layoutOptions != nil) {
            if (layoutOptions!.contains(.assistantMessage) && !layoutOptions!.contains(.summaryMessage)) {
                if (textView?.text.count != nil) {
                    if (textView!.text.count > 20) {
                        oldText = textView!.text
                        newText = String(textView!.text.prefix(20))
                        textView!.font = UIFont.preferredFont(forTextStyle: .caption2)
                    }
                }
            }
        }

    }
    
}


