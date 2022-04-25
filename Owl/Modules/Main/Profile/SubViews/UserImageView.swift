//
//  UserImageView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct UserImageView: View {

    @Binding var animationState: ProfileAnimationState

    var body: some View {
        Image(uiImage: Asset.Images.nastya.image)
            .resizable()
            .scaledToFill()
            .opacity(0.1)
            .cornerRadius(animationState.photoState.cornerRadius)
            .frame(width: animationState.photoState.width, height: animationState.imageViewHeight)
            .offset(x: 0, y: animationState.imageViewYOffset)
            .padding(.top, animationState.imageViewTopPadding)
            .padding(.bottom, animationState.imageViewBottomPadding)
    }
}

// MARK: - ProfileAnimationState

private extension ProfileAnimationState {

    var imageViewHeight: CGFloat {
        switch photoState {
        case .big:
            return photoState.height - offset
        case .small:
            return photoState.height
        }
    }

    var imageViewYOffset: CGFloat {
        switch photoState {
        case .big:
            return offset / 2
        case .small:
            return 0
        }
    }

    var imageViewTopPadding: CGFloat {
        switch photoState {
        case .big:
            return 0
        case .small:
            return safeAreaInsets.top + smallPhotoTopPadding
        }
    }

    var imageViewBottomPadding: CGFloat {
        switch photoState {
        case .big:
            return 0
        case .small:
            return textHeaderSize
        }
    }
    
}
