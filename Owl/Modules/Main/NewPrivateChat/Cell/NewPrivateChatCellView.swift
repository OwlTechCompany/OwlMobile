//
//  NewPrivateChatCellView.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct NewPrivateChatCellView: View {

    let store: Store<NewPrivateChatCell.State, NewPrivateChatCell.Action>

    var body: some View {
        WithViewStore(self.store) { viewStore in

            HStack(alignment: .center, spacing: 16) {

                Image(uiImage: viewStore.image)
                    .resizable()
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(Circle())
                    .scaledToFill()
                    .modifier(ShadowModifier())

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewStore.fullName)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)

                    Text(viewStore.phoneNumber)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12, weight: .regular))
                        .lineLimit(1)
                }

                Spacer()
            }
            .frame(height: 60)
            .padding(.vertical, 8)
            .onTapGesture {
                viewStore.send(.open)
            }
        }
    }
}

// MARK: - Preview

struct NewPrivateChatCellView_Previews: PreviewProvider {
    static var previews: some View {
        NewPrivateChatCellView(store: Store(
            initialState: NewPrivateChatCell.State(
                id: "",
                image: Asset.Images.owlBlack.image,
                fullName: "Denys Danyliuk",
                phoneNumber: "+380992177560"
            ),
            reducer: NewPrivateChatCell.reducer,
            environment: NewPrivateChatCell.Environment()
        ))
    }
}
