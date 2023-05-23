//
//  FirestoreChatsClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 24.08.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension FirestoreChatsClient {

    static let unimplemented = Self(
        openedChatId: CurrentValueSubject(nil),
        getChats: XCTUnimplemented("\(Self.self).getChats"),
        chatWithUser: XCTUnimplemented("\(Self.self).chatWithUser"),
        createPrivateChat: XCTUnimplemented("\(Self.self).createPrivateChat"),
        getLastMessages: XCTUnimplemented("\(Self.self).getLastMessages"),
        subscribeForNewMessages: XCTUnimplemented("\(Self.self).subscribeForNewMessages"),
        getPaginatedMessages: XCTUnimplemented("\(Self.self).getPaginatedMessages"),
        sendMessage: XCTUnimplemented("\(Self.self).sendMessage")
    )

}
