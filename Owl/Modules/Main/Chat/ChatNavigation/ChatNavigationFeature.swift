//
//  ChatNavigationFeature.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct ChatNavigationFeature: Reducer {
    
    struct State: Equatable {
        let photo: Photo
        let chatName: String
        let chatDescription: String
    }
    
    enum Action: Equatable {
        case back
        case chatDetails
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .back:
                return .none
                
            case .chatDetails:
                return .none
            }
        }
    }
    
}

extension ChatNavigationFeature.State {
    
    init(model: ChatsListPrivateItem) {
        self.photo = model.companion.photo
        self.chatName = model.name
        self.chatDescription = model.companion.phoneNumber ?? ""
    }
    
}
