//
//  ChatListCellView.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListCell {

    struct State: Equatable, Identifiable {
        let documentID: String
        let chatImage: UIImage
        let chatName: String
        let lastMessage: String
        let lastMessageSendTime: Date

        public var id: String {
            documentID
        }
    }

    enum Action: Equatable {
        case open
    }

    struct Environment { }

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .open:
            return .none
        }
    }
}

struct ChatListCellView: View {

    let store: Store<ChatListCell.State, ChatListCell.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(alignment: .top, spacing: 16) {
                Image(uiImage: viewStore.chatImage)
                    .frame(width: 56, height: 56)
                    .cornerRadius(19)

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.chatName)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)

                    Text(viewStore.lastMessage)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12, weight: .regular))
                        .lineLimit(2)
                }

                Text(
                    viewStore.lastMessageSendTime,
                    format: Date.FormatStyle().hour().minute()
                )
                .font(.system(size: 12, weight: .regular, design: .monospaced))
            }
            .frame(height: 60)
            .padding(.vertical)
            .onTapGesture {
                viewStore.send(.open)
            }
        }
    }
}

struct ChatListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListCellView(store: Store(
            initialState: ChatListCell.State(
                documentID: "",
                chatImage: Asset.Images.owlBlack.image,
                chatName: "Name Name Name",
                lastMessage: "Cool!😊 let's meet at 16:00 near the shopping mall fklfl",
                lastMessageSendTime: Date()
            ),
            reducer: ChatListCell.reducer,
            environment: ChatListCell.Environment()
        ))
    }
}
