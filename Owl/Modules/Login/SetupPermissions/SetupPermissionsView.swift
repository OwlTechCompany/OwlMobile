//
//  SetupPermissionsView.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct SetupPermissionsView: View {

    var store: Store<SetupPermissions.State, SetupPermissions.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 50) {

                Spacer()

                VStack(spacing: 16.0) {
                    Text("Permissions")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))

                    Text("We need your permission to send you push notifications")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 20.0) {
                    Button(
                        action: { viewStore.send(.later) },
                        label: {
                            Text("Later")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                        }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity)

                    Button(
                        action: { viewStore.send(.grandPermission) },
                        label: { Text("Grand") }
                    )
                    .buttonStyle(BigButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity)
                }

                Spacer()
            }
            .padding(20)
        }
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct SetupPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPermissionsView(store: Store(
            initialState: SetupPermissions.State(),
            reducer: SetupPermissions.reducer,
            environment: SetupPermissions.Environment(
                pushNotificationClient: .live()
            )
        ))
    }
}
