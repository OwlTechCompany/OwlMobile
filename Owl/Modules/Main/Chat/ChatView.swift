//
//  ChatView.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatView: View {

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
                        LazyVStack{
                            ForEachStore(
                                self.store.scope(
                                    state: \.messages,
                                    action: Chat.Action.messages(id:action:)
                                ),
                                content: {
                                    ChatMessageView(store: $0)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(.init())
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                proxy.scrollTo(viewStore.messages.last!.id, anchor: .bottom)
                                            }
                                        }
                                }
                            )
                        }
                    }

                }
                HStack(spacing: 16) {
                    ZStack {
                        TextEditor(text: viewStore.binding(\.$newMessage))
                            .font(.system(size: 16, weight: .regular))

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
                        .onTapGesture { viewStore.send(.sendMessage) }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

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
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(store: Store(
                initialState: .init(model: MockedDataClient.chatsListPrivateItem),
                reducer: Chat.reducer,
                environment: Chat.Environment(chatsClient: .live)
            ))
        }
    }
}
