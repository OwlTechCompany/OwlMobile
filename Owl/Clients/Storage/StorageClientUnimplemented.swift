//
//  StorageClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay

extension StorageClient {

    static let unimplemented = Self(
        compressionQuality: 0.7,
        setMyPhoto: XCTUnimplemented("\(Self.self).setMyPhoto")
    )

}
