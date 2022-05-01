//
//  ChatMessageView.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI
import Firebase

struct ChatMessageView: View {

    let store: Store<ChatMessage.State, ChatMessage.Action>

    @State private var isHStack: Bool = true

    var body: some View {

        WithViewStore(self.store) { viewStore in
            VStack {

                AdaptiveStack(isHStack: $isHStack, spacing: 4) {
                    Text(viewStore.text)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)

                    if let time = viewStore.sentAt?.dateValue() {
                        Text(
                            time,
                            format: Date.FormatStyle().hour().minute()
                        )
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                    } else {
                        Text("Sending..")
                            .font(.system(size: 11, weight: .light, design: .monospaced))
                    }

                }
                .foregroundColor(.white)
                .padding(.vertical, Constants.messagePaddingVertical)
                .padding(.horizontal, Constants.messagePaddingHorizontal)
                .background(viewStore.background)
                .cornerRadius(30, antialiased: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            isHStack = geometry.size.width < Constants.messageMaxWidth
                        }
                    }
                )
                .frame(maxWidth: Constants.bubbleMaxWidth, alignment: viewStore.alignment)

            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(width: screen.width, alignment: viewStore.alignment)
            .onAppear { viewStore.send(.wasShown) }
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
    }

}

private extension ChatMessageView {

    enum Constants {
        static let bubbleMaxWidth = screen.width * 3 / 4
        static let messagePaddingVertical: CGFloat = 12
        static let messagePaddingHorizontal: CGFloat = 16
        static let messageMaxWidth = bubbleMaxWidth - messagePaddingHorizontal * 2
    }

}

private extension ChatMessage.State {

    var alignment: Alignment {
        switch type {
        case .sentByMe:
            return .trailing

        case .sentForMe:
            return .leading
        }
    }

    var textColor: Color {
        switch type {
        case .sentByMe:
            return Color.white

        case .sentForMe:
            return Color.black
        }
    }

    var background: some View {
        switch type {
        case .sentByMe:
            return AnyView(LinearGradient(
                colors: [Colors.Loader.third.swiftUIColor, Colors.violet.swiftUIColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))

        case .sentForMe:
            return AnyView(Colors.Loader.third.swiftUIColor.opacity(0.9))
        }
    }

}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatMessageView(
                store: .init(
                    initialState: .init(
                        id: "",
                        text: "I love you - - - - - - -",
                        sentAt: Timestamp(date: Date()),
                        sentBy: "D. D.",
                        type: .sentByMe
                    ),
                    reducer: ChatMessage.reducer,
                    environment: ChatMessage.Environment()
                )
            )

            // swiftlint:disable line_length
            ChatMessageView(
                store: .init(
                    initialState: .init(
                        id: "",
                        text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam.\n\nEaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                        sentAt: Timestamp(date: Date()),
                        sentBy: "D. D.",
                        type: .sentForMe
                    ),
                    reducer: ChatMessage.reducer,
                    environment: ChatMessage.Environment()
                )
            )
        }
    }
}
