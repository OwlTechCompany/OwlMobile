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
        private static let storage = FirebaseClient.storage
        static let users = storage.reference().child("users")
    }

    var compressionQuality: CGFloat
    var setMyPhoto: (Data) -> Effect<URL, NSError>
}
