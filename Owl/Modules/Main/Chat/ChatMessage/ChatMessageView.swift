//
//  ChatMessageView.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct AdaptiveStack<Content: View>: View {
//    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var isHStack: Bool
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(
        isHStack: Binding<Bool>,
        horizontalAlignment: HorizontalAlignment = .trailing,
        verticalAlignment: VerticalAlignment = .bottom,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isHStack = isHStack
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if isHStack {
                HStack(
                    alignment: verticalAlignment,
                    spacing: spacing,
                    content: content
                )
            } else {
                VStack(
                    alignment: horizontalAlignment,
                    spacing: spacing,
                    content: content
                )
            }
        }
    }
}

struct ChatMessageView: View {

    let store: Store<ChatMessage.State, ChatMessage.Action>

    @State private var isHStack: Bool = false

    var body: some View {

        WithViewStore(self.store) { viewStore in
            VStack {
                AdaptiveStack(isHStack: $isHStack) {
                    Text(viewStore.text)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                    let lines = viewStore.text.lines(
                                        font: .systemFont(ofSize: 16),
                                        width: geometry.size.width
                                    )
                                    isHStack = lines == 1
                                }
                            }
                        )

                    Text(
                        viewStore.sentAt,
                        format: Date.FormatStyle().hour().minute()
                    )
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Colors.loader3.swiftUIColor.opacity(0.3))
                .cornerRadius(30, antialiased: true)
                .frame(
                    maxWidth: screen.width * 3 / 4,
                    alignment: viewStore.type == .sentByMe ? .trailing : .leading
                )
            }
            .padding()
            .frame(
                width: screen.width,
                alignment: viewStore.type == .sentByMe ? .trailing : .leading
            )
        }
    }
}

extension String {

    func lines(font: UIFont, width: CGFloat) -> Int {
        let text = self as NSString
        let textHeight = text.boundingRect(
            with: CGSize(
                width: width,
                height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        ).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
//
//    func lines(font: Font, width: CGFloat) -> Int {
//        let text = self as NSString
//        let textHeight = text.boundingRect(
//            with: CGSize(
//                width: width,
//                height: .greatestFiniteMagnitude),
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        ).height
//        let lineHeight = font.
//        return Int(ceil(textHeight / lineHeight))
//    }
}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatMessageView(
                store: .init(
                    initialState: .init(
                        text: "I love you                               a a a a aa a a a aa",
                        sentAt: Date(),
                        sentBy: "D. D.",
                        type: .sentByMe
                    ),
                    reducer: ChatMessage.reducer,
                    environment: ChatMessage.Environment()
                )
            )

            ChatMessageView(
                store: .init(
                    initialState: .init(
                        text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                        sentAt: Date(),
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
