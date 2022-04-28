//
//  ChatView.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import SwiftUI
import ComposableArchitecture
import Introspect
import UIKit
import Combine

struct ChatView: View {

    @State var isFirstUpdate: Bool = true
    @State var scrollView = UIScrollView()
    @State var keyboard = Keyboard.initialValue

    @FocusState private var focusedField: Field?
    @Environment(\.safeAreaInsets) var safeAreaInsets


    private enum Field: Int, CaseIterable {
        case enterMessage
    }

    let store: Store<Chat.State, Chat.Action>

    init(store: Store<Chat.State, Chat.Action>) {
        self.store = store

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {

        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack {

                            ForEachStore(
                                self.store.scope(
                                    state: \.messages,
                                    action: Chat.Action.messages(id:action:)
                                ),
                                content: {
                                    ChatMessageView(store: $0)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(.init())
                                }
                            )
                        }
                        .onChange(of: viewStore.messages) { newValue in
                            if isFirstUpdate {
                                proxy.scrollTo(newValue.last!.id, anchor: .bottom)
                                isFirstUpdate.toggle()
                            } else {
                                withAnimation {
                                    proxy.scrollTo(newValue.last!.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: focusedField) { _ in }
                    }
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }
                .onTapGesture { focusedField = nil }

                ZStack(alignment: .top) {
                    Rectangle().fill(Colors.Blue._7.swiftUIColor)
                        .frame(height: keyboard.height > 0
                               ? 48 + keyboard.height + 4
                               : 48 + safeAreaInsets.bottom
                        )

                    HStack(spacing: 16) {
                        TextField("Message...", text: viewStore.binding(\.$newMessage))
                            .font(.system(size: 16, weight: .regular))
                            .focused($focusedField, equals: .enterMessage)
                            .disableAutocorrection(true)
                            .keyboardType(UIKit.UIKeyboardType.alphabet)
                            .frame(height: 40)
                            .padding(.horizontal, 4)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Image(systemName: "paperplane")
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                            .background(Colors.accentColor.swiftUIColor)
                            .clipShape(Circle())
                            .onTapGesture {
                                viewStore.send(.sendMessage)
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    .padding(.bottom, safeAreaInsets.bottom)
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .animation(.spring().speed(0.5 / keyboard.duration), value: keyboard)
            }
            .frame(width: screen.width)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChatNavigationView(
                        store: store.scope(
                            state: \.navigation,
                            action: Chat.Action.navigation
                        )
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear { viewStore.send(.onAppear) }
            .onReceive(Publishers.keyboardHeightPublisher) { value in
                keyboard = value
                let contentOffset = scrollView.contentOffset
                scrollView.setContentOffset(
                    .init(x: 0, y: contentOffset.y + value.height),
                    animated: true
                )
            }
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(store: Store(
                initialState: .init(model: MockedDataClient.chatsListPrivateItem),
                reducer: Chat.reducer,
                environment: Chat.Environment(chatsClient: .live(userClient: .live))
            ))
        }
    }
}

struct Keyboard: Equatable {
    var height: CGFloat
    var duration: CGFloat

    static let initialValue = Keyboard(height: 0, duration: 0)
}

extension Publishers {

    static var keyboardHeightPublisher: AnyPublisher<Keyboard, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { value -> (NSValue, NSNumber)? in
                    guard
                        let frame = value.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
                        let duration = value.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                    else {
                        return nil
                    }
                    print(frame.cgRectValue)
                    print(screen.height - frame.cgRectValue.minY)
                    print(frame.cgRectValue.height)
                    return (frame, duration)
                }
                .map { Keyboard(height: $0.cgRectValue.height, duration: $1.doubleValue) },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .compactMap {
                    $0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
                }
                .map { Keyboard(height: 0, duration: $0.doubleValue) }
        )
        .eraseToAnyPublisher()
    }

}
