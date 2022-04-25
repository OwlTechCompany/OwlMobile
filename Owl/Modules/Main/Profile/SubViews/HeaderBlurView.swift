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

                HStack {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 19 / 1.5, height: 34 / 1.5)
                        .foregroundColor(animationState.backColor)
                        .offset(x: 16, y: 0)
                        .onTapGesture { backAction() }

                    Spacer()
                }
                .frame(height: 44)
                .padding(.top, animationState.safeAreaInsets.top)
            }
            .frame(height: animationState.blurHeight)
            .offset(x: 0, y: animationState.headerBlurYOffset)

            Spacer()
        }
        .ignoresSafeArea()
    }
}

// MARK: - ProfileAnimationState

private extension ProfileAnimationState {

    var headerBlurYOffset: CGFloat {
        switch photoState {
        case .big:
            return offset >= 0 ? offset : offset / 2

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
