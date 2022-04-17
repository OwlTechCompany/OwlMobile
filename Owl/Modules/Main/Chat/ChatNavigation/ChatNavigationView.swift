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
            HStack(alignment: .center) {
                Image(systemName: "chevron.backward")
                    .frame(width: 34, height: 34)
                    .foregroundColor(Colors.accentColor.swiftUIColor)
                    .background(Colors.loader3.swiftUIColor.opacity(0.5))
                    .clipShape(Circle())
                    .modifier(ShadowModifier())
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

                viewStore.chatImage
                    .resizable()
                    .frame(width: 42, height: 42)
                    .background(Color.white)
                    .clipShape(Circle())
                    .scaledToFill()
                    .modifier(ShadowModifier())
                    .onTapGesture {
                        viewStore.send(.chatDetails)
                    }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ChatNavigationView(store: Store(
            initialState: MockedDataClient.chatNavigationState,
            reducer: ChatNavigation.reducer,
            environment: .init()
        ))
    }
}
