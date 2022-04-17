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
            .searchable(
                text: viewStore.binding(\.$searchText),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                viewStore.send(.search)
            }
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
}

// MARK: - Preview

struct NewPrivateChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewPrivateChatView(store: Store(
                initialState: NewPrivateChat.State.initialState,
                reducer: NewPrivateChat.reducer,
                environment: NewPrivateChat.Environment()
            ))
        }
    }
}
