//
//  ChatNavigationView.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatNavigationView: View {
    let store: Store<ChatNavigation.State, ChatNavigation.Action>

    var body: some View {

        WithViewStore(self.store) { viewStore in
            ZStack {
                Color.clear.background(.ultraThinMaterial)
                    .ignoresSafeArea(.container, edges: .top)

                HStack(alignment: .center) {
                    Image(systemName: "chevron.backward")
                        .frame(width: 34, height: 34)
                        .foregroundColor(Colors.accentColor.swiftUIColor)
                        .background(Colors.Loader.third.swiftUIColor.opacity(0.5))
                        .clipShape(Circle())
                        .modifier(TinyShadowModifier())
                        .onTapGesture {
                            viewStore.send(.back)
                        }

                    Spacer(minLength: 16)

                    VStack(alignment: .center, spacing: 8) {
                        Text(viewStore.chatName)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))

                        Text(viewStore.chatDescription)
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                    }
                    .lineLimit(1)

                    Spacer(minLength: 16)

                    PhotoWebImage(photo: viewStore.photo, placeholderName: viewStore.chatName, isThumbnail: true)
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                        .onTapGesture { viewStore.send(.chatDetails) }
                }
                .padding(8)
            }
            .frame(height: 44, alignment: .bottom)
        }
    }
}

struct ChatNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ChatNavigationView(store: Store(
            initialState: .init(model: MockedDataClient.chatsListPrivateItem),
            reducer: ChatNavigation.reducer,
            environment: .init()
        ))
    }
}
