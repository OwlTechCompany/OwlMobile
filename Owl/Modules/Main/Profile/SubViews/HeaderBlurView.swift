//
//  HeaderBlurView.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import SwiftUI

struct HeaderBlurView: View {

    @Binding var animationState: ProfileAnimationState

    var backAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.clear.background(.ultraThinMaterial)
                    .opacity(animationState.blurOpacity)

                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 19 / 1.5, height: 34 / 1.5)
                        .foregroundColor(animationState.backColor)
                        .onTapGesture { backAction() }

                    Spacer()
                }
                .frame(height: 44)
                .padding(.top, animationState.safeAreaInsets.top)
                .padding(.horizontal, 16)
            }
            .frame(height: animationState.blurHeight)

            Spacer()
        }
        .offset(x: 0, y: animationState.headerBlurYOffset)
        .animation(nil, value: animationState.photoState)
    }
}

// MARK: - ProfileAnimationState

private extension ProfileAnimationState {

    var headerBlurYOffset: CGFloat {
        switch photoState {
        case .big:
            return offset > 0 ? offset : offset / 2

        case .small:
            return offset
        }
    }

    var backColor: Color {
        return photoState.isScaled ? .white.opacity(0.9) : .black
    }

    var blurHeight: CGFloat {
        return safeAreaInsets.top + textSize
    }

    var blurOpacity: CGFloat {
        let minimumOpacityOffset = smallPhotoMaxY
        let maximumOpacityOffset = smallPhotoMaxY + 20

        switch offset {
        case (...minimumOpacityOffset):
            return 0
        case (minimumOpacityOffset..<maximumOpacityOffset):
            return (offset - minimumOpacityOffset) / (maximumOpacityOffset - minimumOpacityOffset)
        default:
            return 1
        }
    }
    
}
