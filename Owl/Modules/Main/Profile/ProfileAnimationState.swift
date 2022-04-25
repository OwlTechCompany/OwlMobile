//
//  ProfileAnimationState.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct ProfileAnimationState {

    // MARK: - Constants

    let textSize: CGFloat = 44
    let subTextSize: CGFloat = 16
    let textBottomPadding: CGFloat = 16
    let smallPhotoTopPadding: CGFloat = 10
    var textHeaderSize: CGFloat {
        textSize + subTextSize + textBottomPadding
    }

    @Environment(\.safeAreaInsets) var safeAreaInsets

    // MARK: - Variables

    var offset: CGFloat = .zero
    var photoState: ProfilePhotoState = .small

    var smallPhotoMaxY: CGFloat {
        return ProfilePhotoState.small.height + safeAreaInsets.top + smallPhotoTopPadding
    }

    var stackViewHeight: CGFloat {
        switch photoState {
        case .big:
            return screen.width
        case .small:
            return photoState.height + safeAreaInsets.top + textHeaderSize
        }
    }
}
