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

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct CustomScrollView<Content: View>: View {

    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content

    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }

    var body: some View {
        SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.blue.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
                .frame(width: 0, height: 0)
            }
            .frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
    }
}

class Delegate: NSObject, UIScrollViewDelegate, ObservableObject {

//    var scrollViewContentOffset: CGFloat = .zero
    @Published var scrollViewDidScroll: ScrollViewDidScroll?
    @Published var scrollViewDidEndDragging: ScrollViewDidScroll?
//
//    init(scrollViewDidScroll: @escaping (UIScrollView) -> Void) {
//        self.scrollViewDidScroll = scrollViewDidScroll
//    }

    struct ScrollViewDidScroll: Equatable {
        var scrollView: UIScrollView
        var id = UUID()

        static func == (lhs: ScrollViewDidScroll, rhs: ScrollViewDidScroll) -> Bool {
            return lhs.id == rhs.id
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //            scrollViewDidScroll(scrollView)
        //            print("scrollView.contentInset \(scrollView.contentInset)")
//        print("scrollView.contentOffset.y \(scrollView.contentOffset.y)")
        scrollViewDidScroll = .init(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("Here")

//        scrollViewDidEndDragging = nil
//        scrollView.contentOffset = scrollView.contentOffset
        scrollViewDidEndDragging = .init(scrollView: scrollView)
//        print(scrollViewDidEndDragging)
//        let offset = scrollView.contentOffset.y
//        scrollViewContentOffset = offset


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

//enum ScrollState {
//    case small
//    case blur
//    case photoHidden
//
//    var showBlur: Bool {
//        return self == .photoHidden
//    }
//
//    init(offsetY: CGFloat) {
//        let max: CGFloat = 157 + 1
//        switch offsetY {
//        case (..<CGFloat(max / 2)):
//            self = .small
//        case (max / 2..<max):
//            self = .blur
//        case (max...):
//            self = .photoHidden
//            //            case (70...):
//            //                self = .navigation
//        default:
//            print("Default: \(offsetY)")
//            self = .small
//        }
//    }
//}

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
    let subTextSize: CGFloat = 24
    let smallPhotoTopPadding: CGFloat = 10
    var textHeaderSize: CGFloat {
        textSize + subTextSize
    }

    @Environment(\.safeAreaInsets) var safeAreaInsets

    // MARK: - Variables

    var offset: CGFloat = .zero
    var photoState: PhotoState = .small

    var smallPhotoMaxY: CGFloat {
        return PhotoState.small.height + safeAreaInsets.top + smallPhotoTopPadding
    }
}


struct ProfileView: View {

    var store: Store<Profile.State, Profile.Action>

    @State var animationState: AnimationState = .init()

//    @State var offset: CGFloat = .zero
    @ObservedObject var delegate = Delegate()

//    @Environment(\.safeAreaInsets) private var safeAreaInsets

//    @State var scrollState: ScrollState = .init(offsetY: 0)
//    @State var photoState: PhotoState = .small

//    @State var textColor: Color = .black


    var body: some View {
        WithViewStore(store) { _ in
            ScrollView {
                VStack(spacing: 30) {
                    ZStack {
                        UserImageView(animationState: $animationState)
                            .onTapGesture { animationState.photoState.toggle() }

                        HeaderBlurView(animationState: $animationState)

                        HeaderDescriptionView(animationState: $animationState)
                    }
                    .frame(width: screen.width)
                    .zIndex(2)

                    VStack {
                        ForEach(0..<100, id: \.self) { index in
                            HStack {
                                Spacer()
                                Text("\(index)")
                                Spacer()
                            }
                        }
                    }
                    .zIndex(1)
                }
            }
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
                } else if offset > 10 {
                    animationState.photoState = .small
                }
            }
            .onChange(of: delegate.scrollViewDidEndDragging) { value in
                let scrollView = value!.scrollView
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
            .cornerRadius(animationState.photoState.cornerRadius)
            .offset(x: 0, y: animationState.photoState.isScaled ? animationState.offset : 0)
            .frame(
                width: animationState.photoState.width,
                height: animationState.imageViewHeight
            )
            .padding(.top, animationState.photoState.isScaled ? 0 : animationState.safeAreaInsets.top + animationState.smallPhotoTopPadding)
            .padding(.bottom, animationState.photoState.isScaled ? 0 : animationState.textHeaderSize)
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

    var blurHeight: CGFloat {
        safeAreaInsets.top + textSize
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
                .offset(x: 0, y: animationState.imageOffset)
                .offset(x: 0, y: animationState.photoState.isScaled && animationState.offset < 0 ? animationState.offset : 0)
                .foregroundColor(animationState.mainColor)

            Text("+380931314850")
                .foregroundColor(animationState.photoState.isScaled ? .white.opacity(0.7) : .black.opacity(0.7))
                .font(.system(.caption))
                .frame(width: screen.width)
                .frame(height: animationState.subTextSize)
                .offset(x: 0, y: animationState.photoState.isScaled && animationState.offset < 0 ? animationState.offset : 0)
                .opacity(animationState.phoneOpacity)
        }
    }
}

extension AnimationState {
    var mainColor: Color {
        photoState.isScaled ? .white.opacity(0.9) : .black
    }

    var phoneOpacity: CGFloat {
        let max: CGFloat = smallPhotoMaxY - textSize
        return (max - offset) / max
    }

    var imageOffset: CGFloat {
        return offset > (smallPhotoMaxY - textSize) ? offset - (smallPhotoMaxY - textSize) : 0
    }
}

// MARK: - Preview

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(store: Store(
//            initialState: Profile.State(image: Asset.Images.owlWithPadding.image),
//            reducer: Profile.reducer,
//            environment: Profile.Environment()
//        ))
//    }
//}
