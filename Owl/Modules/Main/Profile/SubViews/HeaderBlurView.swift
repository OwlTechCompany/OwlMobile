//
//  HeaderBlurView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct HeaderBlurView: View {

    @Binding var animationState: ProfileAnimationState

    var body: some View {
        VStack {
            Color.clear.background(.ultraThinMaterial)
                .opacity(animationState.blurOpacity)
                .frame(height: animationState.blurHeight, alignment: .top)
                .offset(x: 0, y: animationState.offset)

            Spacer()
        }
    }
}

// MARK: - ProfileAnimationState

private extension ProfileAnimationState {

    var backColor: Color {
        return photoState.isScaled ? .white.opacity(0.9) : .black
    }

    var blurHeight: CGFloat {
        return safeAreaInsets.top + textSize
    }

    var blurOpacity: CGFloat {
        let max: CGFloat = smallPhotoMaxY + 1

        switch offset {
        case (...(max - 10)):
            return 0
        case ((max - 10)..<max + 10):
            return (offset - max + 10) / (20)
        default:
            return 1
        }
    }
    
}
