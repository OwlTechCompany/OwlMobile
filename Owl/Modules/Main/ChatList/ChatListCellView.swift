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
        let unreadMessagesNumber: Int

        public var id: String {
            documentID
        }
    }

    enum Action: Equatable {
        case open
    }

    struct Environment { }

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
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
                    .resizable()
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                    .scaledToFill()
                    .modifier(ShadowModifier())

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

                Spacer(minLength: 0)

                VStack(alignment: .trailing) {
                    Text(
                        viewStore.lastMessageSendTime,
                        format: Date.FormatStyle().hour().minute()
                    )
                    .font(.system(size: 12, weight: .regular, design: .monospaced))

                    ZStack {
                        Text(String(viewStore.unreadMessagesNumber))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(
                                width: viewStore.unreadMessagesWidth,
                                height: Constants.unreadMessagesSize
                            )
                            .fixedSize(horizontal: true, vertical: true)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(
                        width: viewStore.unreadMessagesWidth,
                        height: Constants.unreadMessagesSize
                    )))
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 5)
                    .opacity(viewStore.unreadMessagesNumber == 0 ? 0 : 1)
                }
            }
            .frame(height: 60)
            .padding(.vertical, 8)
            .onTapGesture {
                viewStore.send(.open)
            }
        }
    }
}

private extension ChatListCellView {

    enum Constants {
        static let unreadMessagesSize: CGFloat = 24
    }
}

private extension ChatListCell.State {

    var unreadMessagesWidth: CGFloat {
        let numbersCount = String(unreadMessagesNumber).count
        switch numbersCount {
        case 0:
            return 0

        case 1, 2:
            return ChatListCellView.Constants.unreadMessagesSize

        case 3, 4:
            return CGFloat(numbersCount) * 12

        default:
            return 48
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
                lastMessage: "Cool!😊 let's meet at 16:00. Jklndjf dkf jkss djfn ljf fkhshfkeune fjufuufukk klfn fjj fjufuufukk k",
                lastMessageSendTime: Date(),
                unreadMessagesNumber: 59
            ),
            reducer: ChatListCell.reducer,
            environment: ChatListCell.Environment()
        ))
    }
}
