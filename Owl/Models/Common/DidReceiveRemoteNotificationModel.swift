//
//  DidReceiveRemoteNotificationModel.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import UIKit

struct DidReceiveRemoteNotificationModel: Equatable {
    var userInfo: [AnyHashable: Any]
    var completionHandler: (UIBackgroundFetchResult) -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.userInfo.keys == lhs.userInfo.keys
    }
}
