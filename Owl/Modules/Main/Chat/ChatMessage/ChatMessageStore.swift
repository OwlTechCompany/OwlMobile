//
//  ChatMessageFeature.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI
import Firebase

struct ChatMessageFeature: Reducer {
    
    struct State: Equatable, Identifiable, Hashable {
        let id: String
        let text: String
        let sentAt: Date?
        let sentBy: String // Not used for now; Added for groups
        let type: MessageType
    }
    
    enum MessageType {
        case sentByMe
        case sentForMe
    }
    
    enum Action: Equatable {
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

extension ChatMessageFeature.State {
    
    init(message: MessageResponse, companion: User) {
        self.id = message.id
        self.text = message.messageText
        self.sentAt = message.sentAt
        self.sentBy = message.sentBy
        self.type = message.sentBy == companion.uid ? .sentForMe : .sentByMe
    }
    
}
