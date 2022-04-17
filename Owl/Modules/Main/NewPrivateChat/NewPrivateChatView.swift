//
//  NewPrivateChatView.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct NewPrivateChatView: View {

    var store: Store<NewPrivateChat.State, NewPrivateChat.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                ForEachStore(
                    self.store.scope(
                        state: \NewPrivateChat.State.users,
                        action: NewPrivateChat.Action.users(id:action:)
                    ),
                    content: NewPrivateChatCellView.init(store:)
                )
            }
            .animation(.default, value: viewStore.users)
            .searchable(
                text: viewStore.binding(\.$searchText),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Phone number"
            )
            .onSubmit(of: .search) {
                viewStore.send(.search)
            }
            .overlay(
                viewStore.users.isEmpty
                    ? emptyView
                        .animation(.easeOut, value: viewStore.users.isEmpty)
                    : nil
            )
            .disabled(viewStore.isLoading)
            .overlay(
                viewStore.isLoading
                    ? Loader()
                    : nil
            )
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("New private chat")
    }

    var emptyView: some View {
        VStack {
            Image(systemName: "person.3")
                .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                .font(.system(size: 50, weight: .regular, design: .monospaced))

            Text("Find new contacts.")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// MARK: - Preview

struct NewPrivateChatView_Previews: PreviewProvider {

    static let usersClient = UserClient.live

    static var previews: some View {
        NavigationView {
            NewPrivateChatView(store: Store(
                initialState: NewPrivateChat.State(),
                reducer: NewPrivateChat.reducer,
                environment: NewPrivateChat.Environment(
                    userClient: usersClient,
                    chatsClient: .live(userClient: usersClient),
                    firestoreUsersClient: .live
                )
            ))
        }
    }
}
