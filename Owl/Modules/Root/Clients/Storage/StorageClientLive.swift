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

extension DependencyValues.StorageClientKey: LiveDependencyKey {

    static let liveValue = StorageClient.live(
        userClient: DependencyValues.current.userClient // TODO: This or static props?
    )

}

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

}

fileprivate extension StorageClient {

    static func setMyPhotoLive(
        userClient: UserClient,
        data: Data
    ) -> Effect<URL, NSError> {
        guard let authUser = userClient.authUser.value else {
            return Effect(error: NSError(domain: "No user", code: 1))
        }
        let storageReference = Collection.users.child(authUser.uid)

        return storageReference
            .putData(data)
            .flatMap { _ in storageReference.downloadURL() }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

}
