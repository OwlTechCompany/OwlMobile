//
//  ProfileAnimationState.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI
import Dependencies

struct ProfileAnimationState {

    // MARK: - Constants

    let textSize: CGFloat = 44
    let subTextSize: CGFloat = 16
    let textBottomPadding: CGFloat = 16
    let smallPhotoTopPadding: CGFloat = 10
    var textHeaderSize: CGFloat {
        textSize + subTextSize + textBottomPadding
    }

    @Dependency(\.safeAreaInsets) var safeAreaInsets
    
    // MARK: - Variables

    var offset: CGFloat = .zero
    var photoState: ProfilePhotoState = .small

    var isPlaceholderPhoto: Bool = true

    var smallPhotoMaxY: CGFloat {
        return ProfilePhotoState.small.height + 44 + smallPhotoTopPadding
    }

    var stackViewHeight: CGFloat {
        switch photoState {
        case .big:
            return screen.width
            
        case .small:
            return smallPhotoMaxY + textHeaderSize
        }
    }
}
