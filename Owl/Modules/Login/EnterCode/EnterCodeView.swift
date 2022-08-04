//
//  EnterCodeView.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct EnterCodeView: View {

    var store: Store<EnterCode.State, EnterCode.Action>

    @FocusState private var focusedField: Bool

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {

                Color(UIColor.systemGroupedBackground).ignoresSafeArea(.all)

                VStack(spacing: 48.0) {
                    VStack(spacing: 16.0) {
                        Text("Enter Code")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))

                        VStack(spacing: 8.0) {
                            Text("We have sent you an SMS with the code to")
                            Text(viewStore.phoneNumber)
                        }
                        .font(.system(size: 14, weight: .regular, design: .default))
                    }

                    ZStack {
                        HStack(spacing: 24.0) {
                            ForEach(Constants.codeSizeRange, id: \.self) { index in
                                ZStack {
                                    Circle()
                                        .frame(width: Constants.circleSize, height: Constants.circleSize)
                                        .foregroundColor(
                                            Color.gray.opacity(
                                                Array(viewStore.verificationCode)[safe: index] != nil ? 0 : 0.3
                                            )
                                        )
                                    if Array(viewStore.verificationCode)[safe: Int(index)] != nil {
                                        Text(String(Array(viewStore.verificationCode)[safe: Int(index)]!))
                                            .font(.system(size: Constants.circleSize, weight: .bold, design: .monospaced))
                                    }
                                }
                            }
                        }

                        TextField("", text: viewStore.binding(\.$verificationCode))
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .tint(.clear)
                            .textContentType(.oneTimeCode)
                            .accentColor(.clear)
                            .foregroundColor(.clear)
                            .keyboardType(.numberPad)
                            .frame(
                                width: CGFloat((Constants.codeSize * 2 - 1)) * Constants.circleSize
                            )
                            .focused($focusedField)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    withAnimation {
                                        focusedField = true
                                    }
                                }
                            }
                    }

                    Button(
                        action: { viewStore.send(.resendCode) },
                        label: {
                            Text("Resend Code")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                        }
                    )
                }
            }
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
        .navigationBarTitleDisplayMode(.inline)
    }

    enum Constants {
        static let codeSize = 6
        static let codeSizeRange: Range<Int> = 0 ..< Constants.codeSize
        static let circleSize: CGFloat = 24
    }
}

// MARK: - Preview

struct EnterCodeView_Previews: PreviewProvider {

    static let userClient = UserClient.live(userDefaults: .live())

    static var previews: some View {
        EnterCodeView(
            store: Store(
                initialState: EnterCode.State(
                    verificationCode: "123",
                    phoneNumber: "+380992177560"
                ),
                reducer: EnterCode()
            )
        )
    }
}
