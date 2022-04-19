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



struct ProfileView: View {

    var store: Store<Profile.State, Profile.Action>

    @State var offset: CGFloat = .zero
    @State var photoScaled: Bool = false
    @ObservedObject var delegate = Delegate()

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State var scrollState: ScrollState = .init(offsetY: 0)
    @State var photoState: PhotoState = .small

    enum PhotoState {
        case big
        case small

//        var width: CGFloat {
//            switch
//        }

        func imageOffset(scrollOffset: CGFloat) -> CGFloat {
            switch self {
            case .big:
                return scrollOffset < 0 ? scrollOffset : 0
            case .small:
                return 0
            }
        }

        func imageHeight(scrollOffset: CGFloat, smallInset: CGFloat = 0) -> CGFloat {
            switch self {
            case .big:
                return screen.width - scrollOffset
            case .small:
                return 100 + smallInset
            }
        }

        func imageWidth() -> CGFloat {
            switch self {
            case .big:
                return screen.width
            case .small:
                return 100
            }
        }
    }

    enum ScrollState {
        case small
        case blur
        case photoHidden

        var showBlur: Bool {
            return self == .photoHidden
        }

        func phoneOpacity(offset: CGFloat) -> CGFloat {
            let max: CGFloat = 177 - 44
            let result = (max - offset) / max
            print(result)
            return result
        }

        init(offsetY: CGFloat) {
            let max: CGFloat = 177 + 1
            switch offsetY {
            case (..<CGFloat(max / 2)):
                self = .small
            case (max / 2..<max):
                self = .blur
            case (max...):
                self = .photoHidden
//            case (70...):
//                self = .navigation
            default:
                print("Default: \(offsetY)")
                self = .small
            }
        }
    }

    let textSize: CGFloat = 44 + 16
    let smallImageTopPadding: CGFloat = 30

    var imageMaxY: CGFloat {
        return PhotoState.small.imageHeight(scrollOffset: 0) + safeAreaInsets.top + smallImageTopPadding
    }

//    var image
    // 147 + 30 = 100 heigth 47 safeArea 30 topPadding

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 30) {

                    GeometryReader { proxy in
                        ZStack {
                            Image(uiImage: Asset.Images.nastya.image)
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(photoState == .big ? 0 : 50)
                                .offset(x: 0, y: photoState == .big ? offset : 0)
                                .frame(
                                    width: photoState.imageWidth(),
                                    height: photoState.imageHeight(scrollOffset: offset)
                                )
                                .padding(.top, photoScaled ? 0 : safeAreaInsets.top + smallImageTopPadding)
                                .padding(.bottom, photoScaled ? 0 : textSize)
//                                .ignoresSafeArea(.all, edges: .top)

                            VStack {
                                Color.clear.background(.ultraThinMaterial)
                                    .opacity(scrollState.showBlur ? 1 : 0)
                                    .frame(height: safeAreaInsets.top + textSize, alignment: .top)
                                    .animation(.default, value: scrollState.showBlur)
                                    .offset(x: 0, y: offset)

                                Spacer()
                            }

                            VStack(spacing: 0) {

                                Spacer()

                                Text("Anastasia Holovash")
                                    .font(.system(.headline))
                                    .foregroundColor(.black)
                                    .frame(height: textSize - 16)
                                    .frame(width: screen.width)
                                    .background(Color.red.opacity(0.2))
                                    .offset(x: 0, y: offset > (imageMaxY - textSize + 16) ? offset - (imageMaxY - textSize + 16) : 0)
                                    .offset(x: 0, y: photoScaled ? offset : 0)

                                Text("+380931314850")
                                    .foregroundColor(Color(.secondaryLabel))
                                    .font(.system(.caption))
                                    .frame(width: screen.width)
                                    .frame(height: 16)
//                                    .background(Color.orange.opacity(0.2))
                                    .offset(x: 0, y: photoScaled ? offset : 0)
                                    .opacity(scrollState.phoneOpacity(offset: offset))

                            }
//                            .background(Color.blue)
                        }
                    }

                    .frame(width: screen.width)
                    .frame(
                        height: photoState.imageHeight(
                            scrollOffset: offset,
                            smallInset: safeAreaInsets.top + smallImageTopPadding + textSize
                        )
                    )
                    .onTapGesture {
                        photoScaled.toggle()
                        photoState = photoState == .small ? .big : .small
                    }
                    .zIndex(100)

                    VStack {
                        ForEach(0..<100, id: \.self) { i in
                            HStack {
                                Spacer()
                                Text("\(i)")
                                Spacer()
                            }
                        }
                    }
                    .zIndex(99)
                }
            }
            .onChange(of: delegate.scrollViewDidScroll) { value in
                let newOffset = value!.scrollView.contentOffset.y
                offset = newOffset
                scrollState = ScrollState(offsetY: newOffset)
                print("SCROLL STATE \(scrollState) \(newOffset)")
                if newOffset < -10 {
                    photoState = .big
                    photoScaled = true
                } else if newOffset > 10 {
                    photoState = .small
                    photoScaled = false
                }
            }
            .onChange(of: delegate.scrollViewDidEndDragging) { value in
                let scrollView = value!.scrollView
                let offset = scrollView.contentOffset.y
                if (0..<imageMaxY / 2).contains(offset) {
                    scrollView.setContentOffset(.zero, animated: true)
                } else if (imageMaxY / 2..<imageMaxY).contains(offset) {
                    scrollView.setContentOffset(.init(x: 0, y: imageMaxY), animated: true)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0), value: photoScaled)
            .introspectScrollView { scrollView in
                if scrollView.delegate !== delegate {
                    print("************** setup DELEGATE")
                    scrollView.delegate = delegate
                }
            }
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    Color.clear.background(.ultraThinMaterial)

                    Text("Title")
                        .font(.system(.headline))
//                        .frame(width: .infinity)
//                        .frame(width: .infinity, alignment: .leading)
                }
                .frame(height: 70)
                .frame(maxHeight: .infinity, alignment: .top)
//                .transition(.e)
//                    .hi
                .opacity(offset < -120 ? 1 : 0)
                .animation(.default, value: offset)
                .opacity(0)
            )
        }

//        .edgesIgnoringSafeArea(.all)
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
//        .navigationTitle("Profile")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("Tool")
//            }
//        }
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
