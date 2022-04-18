//
//  SearchBar.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import SwiftUI

struct SearchBar: View {

    // MARK: - FocusedField

    enum FocusedField: Hashable {
        case search
    }

    // MARK: - Properties

    static let searchBarBackgroundColor = Color(
        red: 0.46,
        green: 0.46,
        blue: 0.5
    ).opacity(0.12)

    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState var focusedField: FocusedField?

    let placeholder: String
    let onSubmit: () -> Void

    // MARK: - Lifecycle

    init(
        searchText: Binding<String>,
        isSearching: Binding<Bool> = .constant(false),
        placeholder: String,
        onSubmit: @escaping () -> Void
    ) {
        self._searchText = searchText
        self._isSearching = isSearching
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(SearchBar.searchBarBackgroundColor)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(uiColor: .secondaryLabel))

                TextField(
                    placeholder,
                    text: $searchText,
                    onEditingChanged: { isEditing in
                        withAnimation {
                            isSearching = isEditing
                        }
                    }
                )
                .textFieldStyle(PlainTextFieldStyle())
                .focused($focusedField, equals: .search)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Button("Clear") {
                                searchText = ""
                            }
                            Spacer()
                            Button("Close") {
                                focusedField = nil
                            }
                        }
                    }
                }
                .submitLabel(.search)
                .onSubmit(of: .text) {
                    withAnimation {
                        isSearching = false
                    }
                    onSubmit()
                }
            }
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}
