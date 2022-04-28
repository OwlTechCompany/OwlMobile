//
//  EnterPhoneView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterPhoneView: View {

    private enum Field: Int, CaseIterable {
        case phoneNumber
    }

    var store: Store<EnterPhone.State, EnterPhone.Action>
    @FocusState private var focusedField: Field?

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 50) {
                Spacer()

                VStack(spacing: 16.0) {
                    Text("Enter Phone")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))

                    Text("We will send you SMS to this number to confirm your identity.")
                        .font(.system(size: 14, weight: .regular))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .ignoresSafeArea(.keyboard)
                }

                TextField("Phone number", text: viewStore.binding(\.$phoneNumber))
                    .focused($focusedField, equals: .phoneNumber)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .disableAutocorrection(true)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Done") { focusedField = nil }
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            focusedField = .phoneNumber
                        }
                    }

                Spacer()

                Button(
                    action: { viewStore.send(.sendPhoneNumber) },
                    label: { Text("Send code") }
                )
                .buttonStyle(BigButtonStyle())
                .disabled(!viewStore.isPhoneNumberValid)
            }
            .padding(20)
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
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct EnterPhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneView(store: Store(
            initialState: EnterPhone.State(phoneNumber: "+380992177560", isLoading: false),
            reducer: EnterPhone.reducer,
            environment: EnterPhone.Environment(
                authClient: .live,
                userDefaultsClient: .live(),
                phoneValidation: ValidationClient.live().phoneValidation
            )
        ))
    }
}
