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
    @State var keyboardHeight: CGFloat = 0

    @FocusState private var focusedField: Field?

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
            VStack {
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
                        .onChange(of: focusedField) { value in

                        }
                    }
                }
                .introspectScrollView { scrollView in
                    self.scrollView = scrollView
                }
                .onTapGesture { focusedField = nil }

                HStack(spacing: 16) {
                    ZStack {
                        TextEditor(text: viewStore.binding(\.$newMessage))
                            .font(.system(size: 16, weight: .regular))
                            .focused($focusedField, equals: .enterMessage)
                            .disableAutocorrection(true)
//                            .ignoresSafeArea(.keyboard, edges: .bottom)

                        Text(viewStore.state.newMessage)
                            .font(.system(size: 16, weight: .regular))
                            .opacity(0)
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 4)
                    .background(Colors.textFieldBackground.swiftUIColor)
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
//                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding(.horizontal, 8)
                .padding(.top, 4)
                .padding(.bottom, keyboardHeight + 4)
                .background(Colors.Blue._6.swiftUIColor)
//                .ignoresSafeArea(.keyboard, edges: .bottom)
                .animation(Animation.easeInOut(duration: 0.2), value: keyboardHeight)

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
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear { viewStore.send(.onAppear) }
            .onReceive(Publishers.keyboardHeightPublisher) { value in
                let contentOffset = scrollView.contentOffset
                scrollView.setContentOffset(
                    .init(x: 0, y: contentOffset.y + value),
                    animated: true
                )
                keyboardHeight = value
            }

        }
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

extension Publishers {

    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
       ).eraseToAnyPublisher()
    }

}

// TRY reset the file
