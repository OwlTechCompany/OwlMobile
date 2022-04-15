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

    var body: some View {
        Text("Hello, World!")
            .navigationBarTitleDisplayMode(.inline)

    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(store: Store(
            initialState: .init(),
            reducer: Chat.reducer,
            environment: .init()
        ))
    }
}
