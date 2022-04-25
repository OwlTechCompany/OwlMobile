//
//  HeaderDescriptionView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct HeaderDescriptionView: View {

    @Binding var animationState: ProfileAnimationState

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            Text("Anastasia Holovash")
                .font(.system(.headline))
                .frame(height: animationState.textSize)
                .frame(width: screen.width)
                .scaleEffect(animationState.photoState.isScaled ? 1.5 : 1.1)
                .offset(x: 0, y: animationState.keepInHeaderYOffset)
                .offset(x: 0, y: animationState.stickyOffsetY)
                .foregroundColor(animationState.nameColor)

            Text("+380931314850")
                .foregroundColor(animationState.photoState.isScaled ? .white.opacity(0.7) : .black.opacity(0.7))
                .font(.system(.subheadline))
                .frame(width: screen.width)
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

    var nameMinY: CGFloat {
        return smallPhotoMaxY - textSize
    }
    var nameColor: Color {
        return photoState.isScaled ? .white.opacity(0.9) : .black
    }

    var keepInHeaderYOffset: CGFloat {
        return offset > nameMinY ? offset - nameMinY : 0
    }

    // MARK: - Phone

    var phoneColor: Color {
        return photoState.isScaled ? .white.opacity(0.7) : .black.opacity(0.7)
    }

    var phoneOpacity: CGFloat {
        return (nameMinY - offset) / nameMinY
    }

    // MARK: - Other

    var stickyOffsetY: CGFloat {
        return photoState.isScaled && offset <= 0 ? offset / 2 : 0
    }

}
