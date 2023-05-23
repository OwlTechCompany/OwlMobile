//
//  ChatListView.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListView: View {
    struct ViewState: Equatable {
        let user: User
        
        init(state: ChatListFeature.State) {
            self.user = state.user
        }
    }
    
    private let store: StoreOf<ChatListFeature>
    @StateObject private var viewStore: ViewStore<ViewState, ChatListFeature.Action>
    
    init(store: StoreOf<ChatListFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: ViewState.init))
    }
    
    var body: some View {
        VStack {
            List {
                ForEachStore(
                    store.scope(
                        state: \.chats,
                        action: ChatListFeature.Action.chats(id:action:)
                    ),
                    content: { ChatListCellView(store: $0) }
                )
            }
            .listStyle(.plain)
        }
        .navigationTitle("Owl")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                PhotoWebImage(user: viewStore.user, useResize: true)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .modifier(ShadowModifier())
                    .onTapGesture { viewStore.send(.profileButtonTapped) }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Private chat", action: { viewStore.send(.newPrivateChatButtonTapped) })
                    Button("Group", action: {})
                        .disabled(true)
                } label: {
                    Label("", systemImage: "square.and.pencil")
                }
                .padding()
            }
        }
        .onAppear { viewStore.send(.onAppear) }
        .sheet(
            store: store.scope(state: \.$destination, action: ChatListFeature.Action.destination),
            state: /ChatListFeature.Destination.State.newPrivateChat,
            action: ChatListFeature.Destination.Action.newPrivateChat
        ) { store in
            NavigationStack {
                NewPrivateChatView(store: store)
                    .navigationTitle("New private chat")
            }
        }
    }
}

// MARK: - Preview

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(store: Store(
            initialState: ChatListFeature.State(
                user: User(
                    uid: "",
                    phoneNumber: "",
                    firstName: "",
                    lastName: "",
                    photo: .placeholder
                ),
                chats: .init(
                    arrayLiteral: ChatListCellFeature.State(model: MockedDataClient.chatsListPrivateItem)
                ),
                chatsData: []
            ),
            reducer: ChatListFeature()
        ))
    }
}
