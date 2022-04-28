//
//  SafeAreaInsets+Environment.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {

    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }

    static var defaultValue: EdgeInsets {
        (keyWindow?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {

    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
