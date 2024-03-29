//
//  EditProfileView.swift
//  Owl
//
//  Created by Denys Danyliuk on 27.04.2022.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct EditProfileView: View {
    
    private enum Field: Int, CaseIterable {
        case firstName
        case lastName
    }
    
    let store: StoreOf<EditProfileFeature>
    // TODO: Maybe use ViewState
    @ObservedObject private var viewStore: ViewStoreOf<EditProfileFeature>
    @FocusState private var focusedField: Field?
    
    init(store: StoreOf<EditProfileFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 50.0) {
                    
                    imageSelectView
                    
                    textFields
                    
                    Spacer()
                    
                    Button(
                        action: { viewStore.send(.save) },
                        label: { Text("Save") }
                    )
                    .buttonStyle(BigButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .padding(20)
                .frame(minHeight: proxy.size.height)
            }
        }
        .disabled(viewStore.isLoading)
        .overlay(viewStore.isLoading ? Loader() : nil)
        .alert(
            self.store.scope(state: \.alert),
            dismiss: .dismissAlert
        )
        .sheet(isPresented: viewStore.binding(\.$showImagePicker)) {
            ImagePicker(
                sourceType: .photoLibrary,
                selectedImage: viewStore.binding(\.$selectedImage)
            )
        }
        
        .background(
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var imageSelectView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let selectedImage = viewStore.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .background(Color.white)
                        .clipShape(Circle())
                } else {
                    PhotoWebImage(
                        photo: viewStore.photo,
                        placeholderName: viewStore.firstName,
                        isThumbnail: false
                    )
                    .clipShape(Circle())
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(50)
            .onTapGesture { viewStore.send(.showImagePicker) }
            
            Image(systemName: "pencil.circle.fill")
                .offset(x: 5, y: 5)
                .font(.system(size: 24.0))
                .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
        }
    }
    
    var textFields: some View {
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
    }
}

// MARK: - Preview

struct EditProfileView_Previews: PreviewProvider {
    
    static let userClient = UserClient.live()
    
    static var previews: some View {
        EditProfileView(store: Store(
            initialState: EditProfileFeature.State(
                user: User(
                    uid: "",
                    phoneNumber: "",
                    firstName: "",
                    lastName: "",
                    photo: .placeholder
                )
            ),
            reducer: EditProfileFeature()
        ))
    }
}
