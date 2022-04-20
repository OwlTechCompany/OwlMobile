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

class Delegate: NSObject, UITableViewDelegate, ObservableObject {

    @Published var scrollViewDidScroll: ScrollViewDidScroll?
    @Published var scrollViewDidEndDragging: ScrollViewDidScroll?

    struct ScrollViewDidScroll: Equatable {
        var scrollView: UIScrollView
        var id = UUID()

        static func == (lhs: ScrollViewDidScroll, rhs: ScrollViewDidScroll) -> Bool {
            return lhs.id == rhs.id
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("-----scrollViewDidScroll\(scrollView.contentOffset.y)")
        scrollViewDidScroll = ScrollViewDidScroll(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("!!!!!scrollViewDidEndDragging\(scrollView.contentOffset.y)")
        scrollViewDidEndDragging = ScrollViewDidScroll(scrollView: scrollView)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        print("+++++++scrollViewShouldScrollToTop")
        return true
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        print("~~~~~~~scrollViewDidChangeAdjustedContentInset")
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {

    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}


enum PhotoState {
    case big
    case small

    var height: CGFloat {
        switch self {
        case .big:
            return screen.width
        case .small:
            return 100
        }
    }

    var width: CGFloat {
        switch self {
        case .big:
            return screen.width
        case .small:
            return 100
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .big:
            return 0
        case .small:
            return height / 2
        }
    }

    var isScaled: Bool {
        return self == .big
    }

    mutating func toggle() {
        switch self {
        case .big:
            self = .small
        case .small:
            self = .big
        }
    }
}

struct AnimationState {

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
    var photoState: PhotoState = .small

    var smallPhotoMaxY: CGFloat {
        return PhotoState.small.height + safeAreaInsets.top + smallPhotoTopPadding
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

struct ProfileView: View {

    var store: Store<Profile.State, Profile.Action>

    @ObservedObject var delegate = Delegate()
    @State var animationState = AnimationState()

    @Environment(\.presentationMode) var presentationMode

//    var scrollView: UIScrollView

    var body: some View {
        WithViewStore(store) { _ in
            ScrollView {
                VStack(spacing: 30) {
                    GeometryReader { proxy in
                        ZStack {
                            UserImageView(animationState: $animationState)
                                .onTapGesture { animationState.photoState.toggle() }

                            HeaderBlurView(animationState: $animationState)

                            HeaderDescriptionView(animationState: $animationState)

                            Text("\(proxy.frame(in: .global).minY)")
                                .offset(x: 0, y: 100)
                        }
                        .frame(width: screen.width)
                        .frame(height: animationState.stackViewHeight)
                        .background(Color.red.opacity(0.2))
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
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

                        Button(
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

                        Button(
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

                        Button(
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

                        Button(
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

                        Button(
                            action: {
                                print("Perform an action here...")
                            },
                            label: {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .frame(height: 44)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                        .padding(.horizontal)

//                        Spacer(minLength: 500)
                    }
                }
                .zIndex(1)
            }
//            .overlay {
//                VStack {
//                    HStack(alignment: .center) {
//                        Image(systemName: "chevron.backward")
//                            .scaleEffect(1.5)
//                            .foregroundColor(animationState.backColor)
//                            .padding(.leading, 20)
//                            .onTapGesture {
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                        Spacer()
//                    }
//                    .frame(height: 44)
//                    .padding(.top, animationState.safeAreaInsets.top)
//
//                    Spacer()
//                }
//                .frame(width: screen.width)
//            }
            .onChange(of: animationState.photoState) { newValue in
                switch newValue {
                case .big:
                    generateFeedback()
                case .small:
                    break
                }
            }
            .onChange(of: delegate.scrollViewDidScroll) { value in
                let offset = value!.scrollView.contentOffset.y
                animationState.offset = offset
                if offset < -10 {
                    animationState.photoState = .big
                } else if offset > 5 && animationState.photoState == .big {
//                    scrollView.dece
                    animationState.photoState = .small
                }
            }
            .onChange(of: delegate.scrollViewDidEndDragging) { value in
                let scrollView = value!.scrollView
                let offset = scrollView.contentOffset.y
                let hidePhotoOffset = animationState.smallPhotoMaxY
                let edgePosition = hidePhotoOffset / 2
                print("hidePhotoOffset \(hidePhotoOffset)")

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
            .introspectScrollView { scrollView in
                if scrollView.delegate !== delegate {
                    scrollView.delegate = delegate
                }
            }
            .ignoresSafeArea()
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

    func generateFeedback() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }
}

struct UserImageView: View {

    @Binding var animationState: AnimationState

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
//            .animation(
//                Animation.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0),
//                value: animationState.photoState
//            )
    }
}

private extension AnimationState {

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


struct HeaderBlurView: View {

    @Binding var animationState: AnimationState

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

private extension AnimationState {
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


struct HeaderDescriptionView: View {

    @Binding var animationState: AnimationState

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
//        .animation(
//            Animation.easeIn(duration: 0.35),
//            value: animationState.photoState
//        )
    }
}

private extension AnimationState {

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

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: Store(
            initialState: Profile.State(image: Asset.Images.owlWithPadding.image),
            reducer: Profile.reducer,
            environment: Profile.Environment()
        ))
    }
}
