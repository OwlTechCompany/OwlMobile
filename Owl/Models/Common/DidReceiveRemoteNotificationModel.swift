//
//  DidReceiveRemoteNotificationModel.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import UIKit

class DidReceiveRemoteNotificationModel: Equatable {


    var userInfo: [AnyHashable: Any]
    var completionHandler: (UIBackgroundFetchResult) -> Void

    init(userInfo: [AnyHashable : Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.userInfo = userInfo
        self.completionHandler = completionHandler
    }

    static func == (lhs: DidReceiveRemoteNotificationModel, rhs: DidReceiveRemoteNotificationModel) -> Bool {
        return lhs.userInfo.keys == lhs.userInfo.keys
    }
}
