//
//  UserImageView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserImageView: View {

    @Binding var animationState: ProfileAnimationState

    var user: User

    var body: some View {
        PhotoWebImage(user: user, useResize: false)
            .frame(width: animationState.photoState.width, height: animationState.imageViewHeight)
            .cornerRadius(animationState.photoState.cornerRadius)
            .overlay(
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [
                            .black.opacity(0),
                            .black.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: animationState.textHeaderSize + 20)
                }
                .opacity(animationState.photoState == .big ? 1 : 0)
            )
            .overlay(
                VStack {
                    LinearGradient(
                        colors: [
                            .black.opacity(0.2),
                            .black.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: animationState.safeAreaInsets.top + animationState.textSize + 10)

                    Spacer()
                }
                .opacity(animationState.photoState == .big ? 1 : 0)
            )
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
