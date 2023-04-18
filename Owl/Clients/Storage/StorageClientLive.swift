//
//  StorageClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import Combine
import ComposableArchitecture
import Firebase
import FirebaseStorage
import FirebaseStorageCombineSwift
import CoreGraphics

extension StorageClient {

    static func live() -> StorageClient {
        @Dependency(\.userClient) var userClient
        return StorageClient(
            compressionQuality: 0.4,
            setMyPhoto: {
                setMyPhotoLive(
                    userClient: userClient,
                    data: $0
                )
            }
        )
    }

}

fileprivate extension StorageClient {

    static func setMyPhotoLive(
        userClient: UserClient,
        data: Data
    ) -> EffectPublisher<URL, NSError> {
        guard let authUser = userClient.authUser.value else {
            return EffectPublisher(error: NSError(domain: "No user", code: 1))
        }
        let storageReference = Collection.users.child(authUser.uid)

        return storageReference
            .putData(data)
            .flatMap { _ in storageReference.downloadURL() }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

}
