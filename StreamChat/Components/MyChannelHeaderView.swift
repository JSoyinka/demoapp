//
// Copyright © 2024 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatUI
import Contacts

class CustomChatChannelHeaderView: ChatChannelHeaderView {
    
    // The subtitleText is responsible to render the status of the members.
    override var titleText: String? {
        let store = CNContactStore()
        var userNumber : CNPhoneNumber
        var assistantEnabled = true
        if ((channelController?.channel?.extraData["is_cool"]?.boolValue) != nil) {
            if (channelController!.channel!.extraData["is_cool"]!.boolValue!) {
                assistantEnabled = false
            }
        }
        
        if ((channelController?.channel?.name) != nil) {
            userNumber = CNPhoneNumber(stringValue: channelController!.channel!.name!)
            do {
                let predicate = CNContact.predicateForContacts(matching: userNumber)
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                
                if (contacts.count > 0) {
                    if assistantEnabled {
                        return contacts[0].givenName + " " + contacts[0].familyName
                    } else {
                        return "★ " + contacts[0].givenName + " " + contacts[0].familyName
                    }
                } else {
                    if assistantEnabled {
                        return super.titleText
                    } else {
                        return "★ " + (super.titleText ?? "")
                    }
                }
            } catch {
                NSLog("Failed to fetch contact, error: \(error)")
                // Handle the error.
            }
        }
        return super.titleText
    }
}


