//
//  HeaderDescriptionView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct HeaderDescriptionView: View {

    @Binding var animationState: ProfileAnimationState

    var title: String
    var subtitle: String

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            Text(title)
                .font(.system(.headline))
                .frame(height: animationState.textSize)
//                .frame(width: screen.width)
                .scaleEffect(animationState.photoState.isScaled ? 1.5 : 1)
                .offset(x: 0, y: animationState.keepInHeaderYOffset)
                .offset(x: 0, y: animationState.stickyOffsetY)
                .foregroundColor(animationState.nameColor)

            Text(subtitle)
                .foregroundColor(animationState.photoState.isScaled ? .white.opacity(0.7) : .black.opacity(0.7))
                .font(.system(.subheadline))
//                .frame(width: screen.width)
                .frame(height: animationState.subTextSize)
                .offset(x: 0, y: animationState.stickyOffsetY)
                .opacity(animationState.phoneOpacity)
                .padding(.bottom, animationState.textBottomPadding)
        }
    }
}

// MARK: - ProfileAnimationState

private extension ProfileAnimationState {

    // MARK: - Name

    var maximumNameOffsetY: CGFloat {
        return smallPhotoMaxY - safeAreaInsets.top
    }

    var nameColor: Color {
        return photoState.isScaled ? .white : .black
    }

    var keepInHeaderYOffset: CGFloat {
        return offset >= maximumNameOffsetY ? offset - maximumNameOffsetY : 0
    }

    // MARK: - Phone

    var phoneColor: Color {
        return photoState.isScaled ? .white.opacity(0.9) : .black.opacity(0.7)
    }

    var phoneOpacity: CGFloat {
        return (maximumNameOffsetY - offset) / maximumNameOffsetY
    }

    // MARK: - Other

    var stickyOffsetY: CGFloat {
        return photoState.isScaled && offset <= 0 ? offset / 2 : 0
    }

}
