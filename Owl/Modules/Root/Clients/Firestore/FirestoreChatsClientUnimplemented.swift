//
//  FirestoreChatsClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension DependencyValues {

    var firestoreChatsClient: FirestoreChatsClient {
        get { self[FirestoreChatsClientKey.self] }
        set { self[FirestoreChatsClientKey.self] = newValue }
    }

    enum FirestoreChatsClientKey: LiveDependencyKey {
        static var testValue = FirestoreChatsClient.unimplemented
        static var liveValue = FirestoreChatsClient.live(
            userClient: DependencyValues.current.userClient
        )
    }

}

extension FirestoreChatsClient {

    static let unimplemented = Self(
        openedChatId: CurrentValueSubject(nil),
        getChats: XCTUnimplemented("\(Self.self).getChats"),
        chatWithUser: XCTUnimplemented("\(Self.self).chatWithUser"),
        createPrivateChat: XCTUnimplemented("\(Self.self).createPrivateChat"),
        getMessages: XCTUnimplemented("\(Self.self).getMessages"),
        sendMessage: XCTUnimplemented("\(Self.self).sendMessage")
    )

}
