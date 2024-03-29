//
//  ProfileView.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import SwiftUI
import ComposableArchitecture
import Introspect
import UIKit

struct ProfileView: View {

    let store: StoreOf<ProfileFeature>

    @ObservedObject var delegate = ScrollViewDelegate()
    @State var animationState = ProfileAnimationState()
    @Environment(\.presentationMode) var presentationMode
    
    init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 30) {
                    ZStack {
                        UserImageView(
                            animationState: $animationState,
                            user: viewStore.user
                        )
                        .onTapGesture {
                            guard !animationState.isPlaceholderPhoto else {
                                return
                            }
                            animationState.photoState.toggle()
                        }

                        HeaderBlurView(
                            animationState: $animationState,
                            backAction: { viewStore.send(.close) },
                            editAction: { viewStore.send(.edit) }
                        )

                        HeaderDescriptionView(
                            animationState: $animationState,
                            title: viewStore.user.fullName,
                            subtitle: viewStore.user.phoneNumber ?? "hidden"
                        )
                    }
                    .frame(width: screen.width)
                    .frame(height: animationState.stackViewHeight)
                    .zIndex(2)

                    VStack(spacing: 20) {

                        sectionButton(
                            image: "bookmark.square.fill",
                            imageColor: .blue,
                            text: "Saved messages",
                            action: { }
                        )

                        sectionButton(
                            image: "bell.square.fill",
                            imageColor: .red,
                            text: "Notifications",
                            action: { }
                        )

                        sectionButton(
                            image: "lock.square.fill",
                            imageColor: .gray,
                            text: "Privacy and security",
                            action: { }
                        )

                        Spacer(minLength: 50)

                        Button(
                            action: { viewStore.send(.logoutTapped) },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)
                    }
                }
                .zIndex(1)
            }
            .introspectScrollView { scrollView in
                if scrollView.delegate !== delegate {
                    scrollView.delegate = delegate
                }
            }
            .onChange(of: animationState.photoState) { newValue in
                switch newValue {
                case .big:
                    generateFeedback(style: .heavy)
                case .small:
                    generateFeedback(style: .soft)
                }
            }
            .onChange(of: viewStore.user) { newValue in
                animationState.isPlaceholderPhoto = newValue.photo == .placeholder
            }
            .onChange(of: delegate.scrollViewDidScroll) { value in
                guard let scrollView = value?.scrollView else {
                    return
                }
                let offset = scrollView.contentOffset.y
                animationState.offset = offset

                guard !animationState.isPlaceholderPhoto else {
                    return
                }
                if offset <= -32 {
                    animationState.photoState = .big
                } else if offset >= 1 {
                    animationState.photoState = .small
                }
            }
            .onChange(of: delegate.scrollViewDidEndDragging) { value in
                guard let scrollView = value?.scrollView else {
                    return
                }
                let offset = scrollView.contentOffset.y
                let hidePhotoOffset = animationState.smallPhotoMaxY
                let edgePosition = hidePhotoOffset / 2

                switch offset {
                case (0..<edgePosition):
                    scrollView.setContentOffset(.zero, animated: true)

                case (edgePosition..<hidePhotoOffset):
                    scrollView.setContentOffset(
                        CGPoint(x: 0, y: hidePhotoOffset),
                        animated: true
                    )

                default:
                    break
                }
            }
            .animation(
                Animation.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0),
                value: animationState.photoState
            )
            .ignoresSafeArea()
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
            .onAppear {
                viewStore.send(.onAppear)
                animationState.isPlaceholderPhoto = viewStore.user.photo == .placeholder
            }
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
    }

    func sectionButton(
        image: String,
        imageColor: Color,
        text: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 10) {
                    Image(systemName: image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(imageColor)
                        .padding(.leading, 7)

                    Text(text)
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium, design: .rounded))

                    Spacer()
                }
            }
        )
        .frame(height: 44)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
        .padding(.horizontal)
    }

    func generateFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactHeavy = UIImpactFeedbackGenerator(style: style)
        impactHeavy.impactOccurred()
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: Store(
            initialState: ProfileFeature.State(
                user: User(
                    uid: "",
                    phoneNumber: "",
                    firstName: "",
                    lastName: "",
                    photo: .placeholder
                )
            ),
            reducer: ProfileFeature()
        ))
    }
}
