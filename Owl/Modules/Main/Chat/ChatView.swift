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

// TODO: This view needs refactor
struct ChatView: View {

    @State var isFirstUpdate: Bool = true
    @State var scrollView = UIScrollView()
    @State var keyboard = Keyboard.initialValue

    @FocusState private var focusedField: Field?
    @Environment(\.safeAreaInsets) var safeAreaInsets

    let store: StoreOf<ChatFeature>

    init(store: StoreOf<ChatFeature>) {
        self.store = store

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {

        WithViewStore(store) { viewStore in
            ZStack {
                VStack {
                    ChatNavigationView(
                        store: store.scope(
                            state: \.navigation,
                            action: ChatFeature.Action.navigation
                        )
                    )

                    Spacer()
                }
                .zIndex(1)

                VStack(spacing: 0) {
                    ScrollView {
                        ScrollViewReader { proxy in
                            LazyVStack {
                                ForEachStore(
                                    self.store.scope(
                                        state: \.messages,
                                        action: ChatFeature.Action.messages(id:action:)
                                    ),
                                    content: {
                                        ChatMessageView(store: $0)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(.init())
                                            .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                                    }
                                )
                            }
                            .onChange(of: viewStore.messages) { newValue in
                                guard
                                    let lastMessage = newValue.first,
                                    isFirstUpdate
                                else {
                                    return
                                }
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                isFirstUpdate.toggle()
                            }
                            .onChange(of: viewStore.newMessages) { newValue in
                                guard
                                    let lastMessage = newValue.first,
                                    lastMessage.sentBy != viewStore.companion.uid
                                else {
                                    return
                                }
                                withAnimation { proxy.scrollTo(lastMessage.id, anchor: .bottom) }
                            }
                            .animation(.none, value: keyboard)

                            Rectangle()
                                .foregroundColor(Color(.systemGroupedBackground))
                                .frame(height: safeAreaInsets.top + 44)
                        }
                    }
                    .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                    .introspectScrollView { scrollView in self.scrollView = scrollView }
                    .onTapGesture { focusedField = nil }
                    .ignoresSafeArea(.all, edges: .top)

                    textField
                }
                .zIndex(0)
                .frame(width: screen.width)
                .navigationBarBackButtonHidden(true)
                .onAppear { viewStore.send(.onAppear) }
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }

    var textField: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Colors.Blue._7.swiftUIColor)
                        .frame(height: 1)

                    Rectangle()
                        .fill(Color(.systemGroupedBackground))
                        .frame(height: textFieldBackgroundHeight)
                }

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
        : Constants.textFieldBackgroundHeigh + 6
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
                initialState: ChatFeature.State(model: MockedDataClient.chatsListPrivateItem),
                reducer: ChatFeature()
            ))
        }
    }

}
