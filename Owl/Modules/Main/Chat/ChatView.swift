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
                            guard let lastMessage = newValue.last else {
                                return
                            }
                            if isFirstUpdate {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                isFirstUpdate.toggle()
                            } else {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .animation(.none, value: keyboard)
                    }
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }
                .onTapGesture { focusedField = nil }

                textField
            }
            .animation(.spring().speed(0.5 / keyboard.duration), value: keyboard)
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
            .onReceive(Publishers.keyboardHeightPublisher) { newValue in
                if keyboard.height != newValue.height {
                    keyboard = newValue
                    scrollView.setContentOffset(
                        .init(x: 0, y: scrollView.contentOffset.y + scrollViewContentOffsetY),
                        animated: true
                    )
                }
            }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }

    var textField: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .top) {
                Rectangle().fill(Colors.Blue._7.swiftUIColor)
                    .frame(height: textFieldBackgroundHeight)

                HStack(spacing: 16) {
                    TextField("Message...", text: viewStore.binding(\.$newMessage))
                        .font(.system(size: 16, weight: .regular))
                        .focused($focusedField, equals: .enterMessage)
                        .disableAutocorrection(true)
                        .keyboardType(UIKit.UIKeyboardType.alphabet)
                        .frame(height: Constants.textFieldHeight)
                        .padding(.horizontal, 4)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Image(systemName: "paperplane")
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .background(Colors.accentColor.swiftUIColor)
                        .clipShape(Circle())
                        .onTapGesture { viewStore.send(.sendMessage) }
                }
                .padding(.horizontal, 8)
                .padding(.top, Constants.textFieldVerticalPadding)
                .padding(.bottom, safeAreaInsets.bottom)
            }
        }
    }

}

// MARK: - Extension

private extension ChatView {

    var keyboardIsUp: Bool {
        keyboard.height > 0
    }

    var textFieldBackgroundHeight: CGFloat {
        keyboardIsUp
        ? Constants.textFieldBackgroundHeigh + keyboard.height + Constants.editionTextFieldBottomPadding
        : Constants.textFieldBackgroundHeigh + safeAreaInsets.bottom
    }

    var scrollViewContentOffsetY: CGFloat {
        keyboardIsUp ? keyboard.height - safeAreaInsets.bottom + 6 : 0
    }

    var needsScrollToNewMessage: Bool {
        return true
    }

}

// MARK: - Declarations

private extension ChatView {

    enum Field: Int, CaseIterable {
        case enterMessage
    }

}

private enum Constants {
    static let textFieldHeight: CGFloat = 40
    static let textFieldVerticalPadding: CGFloat = 4
    static let textFieldBackgroundHeigh: CGFloat = textFieldHeight + textFieldVerticalPadding * 2
    static let editionTextFieldBottomPadding: CGFloat = 4
}

// MARK: - Preview

struct ChatView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ChatView(store: Store(
                initialState: .init(model: MockedDataClient.chatsListPrivateItem),
                reducer: Chat.reducer,
                environment: Chat.Environment(chatsClient: .live(userClient: .live(userDefaults: .live())))
            ))
        }
    }

}
