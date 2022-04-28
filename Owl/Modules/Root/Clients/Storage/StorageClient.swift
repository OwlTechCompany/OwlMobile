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

struct StorageClient {

    enum Collection {
        private static let db = Storage.storage()
        static let users = db.reference().child("users")
    }

    var compressionQuality: CGFloat
    var setMyPhoto: (Data) -> Effect<URL, NSError>
}

// MARK: - Live

extension StorageClient {

    static func live(userClient: UserClient) -> StorageClient {
        StorageClient(
            compressionQuality: 0.4,
            setMyPhoto: {
                setMyPhotoLive(
                    userClient: userClient,
                    data: $0
                )
            }
        )
    }

    static private func setMyPhotoLive(
        userClient: UserClient,
        data: Data
    ) -> Effect<URL, NSError> {
        guard let authUser = userClient.authUser.value else {
            return Effect(error: NSError(domain: "No user", code: 1))
        }
        let storageReference = Collection.users.child("\(authUser.uid)")

        return storageReference
            .putData(data)
            .flatMap { _ in storageReference.downloadURL() }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
}
