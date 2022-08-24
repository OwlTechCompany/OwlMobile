//
//  StorageClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 26.04.2022.
//

import Combine
import ComposableArchitecture
import Firebase
import FirebaseStorage
import FirebaseStorageCombineSwift
import CoreGraphics
import XCTestDynamicOverlay

struct StorageClient {

    enum Collection {
        private static let storage = FirebaseClient.storage
        static let users = storage.reference().child("users")
    }

    var compressionQuality: CGFloat
    var setMyPhoto: (Data) -> Effect<URL, NSError>
}

extension DependencyValues {

    var storageClient: StorageClient {
        get { self[StorageClientKey.self] }
        set { self[StorageClientKey.self] = newValue }
    }

    enum StorageClientKey: DependencyKey {
        static var testValue = StorageClient.unimplemented
        static let liveValue = StorageClient.live(
            userClient: DependencyValues.current.userClient
        )
    }

}
