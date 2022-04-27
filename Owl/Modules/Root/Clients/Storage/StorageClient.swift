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

struct StorageClient {

    enum Collection {
        private static let db = Storage.storage()
        static let users = db.reference().child("users")
    }
    
    static var cancellables = Set<AnyCancellable>()

    var setMyPhoto: (Data) -> Effect<URL, NSError>
}

// MARK: - Live

extension StorageClient {

    static func live(userClient: UserClient) -> StorageClient {
        StorageClient(
            setMyPhoto: { setMyPhotoLive(userClient: userClient, data: $0) }
        )
    }

    static private func setMyPhotoLive(
        userClient: UserClient,
        data: Data
    ) -> Effect<URL, NSError> {
        Effect.future { callback in
            guard let authUser = userClient.authUser.value else {
                return callback(.failure(.init(domain: "No user", code: 1)))
            }
            let storageReference = Collection.users.child("\(authUser.uid)")

            storageReference
                .putData(data)
                .catch { error -> AnyPublisher<StorageMetadata, Never> in
                    callback(.failure(error as NSError))
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                .flatMap { _ in storageReference.downloadURL() }
                .on(
                    value: { callback(.success($0)) },
                    error: { callback(.failure($0 as NSError)) }
                )
                .sink()
                .store(in: &cancellables)
        }
    }
}
