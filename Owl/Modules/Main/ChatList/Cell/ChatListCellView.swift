//
//  ChatListCellView.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListCellView: View {

    let store: StoreOf<ChatListCellFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .top, spacing: 16) {
                PhotoWebImage(photo: viewStore.photo, placeholderName: viewStore.chatName, isThumbnail: true)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .modifier(ShadowModifier())

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewStore.chatName)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)

                    Text(viewStore.lastMessageAuthorName)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12, weight: .semibold))
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
                    .background(LinearGradient(
                        colors: [Colors.Loader.third.swiftUIColor, Color.accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
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
            .background(Color.white)
            .onTapGesture {
                viewStore.send(.open)
            }
        }
    }
}

// MARK: - Extensions

private extension ChatListCellView {

    enum Constants {
        static let unreadMessagesSize: CGFloat = 24
    }
}

private extension ChatListCellFeature.State {

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

// MARK: - Preview

struct ChatListCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListCellView(store: Store(
            initialState: ChatListCellFeature.State(model: MockedDataClient.chatsListPrivateItem),
            reducer: ChatListCellFeature()
        ))
    }
}
