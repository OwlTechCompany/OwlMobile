//
//  EnterUserDataView.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterUserDataView: View {

    private enum Field: Int, CaseIterable {
        case firstName
        case lastName
    }

    var store: Store<EnterUserData.State, EnterUserData.Action>
    @FocusState private var focusedField: Field?

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in

                ScrollView(.vertical, showsIndicators: false) {

                    VStack(spacing: 50.0) {

                        Spacer()

                        VStack(spacing: 16.0) {
                            Text("Profile information")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))

                            Text("This data will be visible for everyone")
                                .font(.system(size: 14, weight: .regular, design: .default))
                        }

                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: Asset.Images.owlWithPadding.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .background(Color.white)
                                .clipShape(Circle())

                            Image(systemName: "pencil.circle.fill")
                                .offset(x: 5, y: 5)
                                .font(.system(size: 24.0))
                                .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                        }

                        VStack(spacing: 24) {
                            TextField("Your first name", text: viewStore.binding(\.$firstName))
                                .textContentType(.givenName)
                                .focused($focusedField, equals: .firstName)
                                .onSubmit { focusedField = .lastName }

                            TextField("Your last name", text: viewStore.binding(\.$lastName))
                                .textContentType(.familyName)
                                .focused($focusedField, equals: .lastName)
                        }
                        .multilineTextAlignment(.center)
                        .keyboardType(.namePhonePad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .disableAutocorrection(true)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                HStack {
                                    Spacer()
                                    Button("Done") { focusedField = nil }
                                }
                            }
                        }

                        Spacer()

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
                                action: { viewStore.send(.save) },
                                label: { Text("Save") }
                            )
                            .buttonStyle(BigButtonStyle())
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .disabled(!viewStore.saveButtonEnabled)
                        }
                    }
                    .padding(20)
                    .frame(minHeight: proxy.size.height)
                    .disabled(viewStore.isLoading)
                    .overlay(
                        viewStore.isLoading
                            ? Loader()
                            : nil
                    )
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .dismissAlert
                    )
                }
            }
        }
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct EnterUserDataView_Previews: PreviewProvider {
    static var previews: some View {
        EnterUserDataView(store: Store(
            initialState: EnterUserData.State(),
            reducer: EnterUserData.reducer,
            environment: EnterUserData.Environment(
                authClient: .live,
                firestoreUsersClient: .live
            )
        ))
    }
}
