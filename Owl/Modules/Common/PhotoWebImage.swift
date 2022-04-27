//
//  PhotoWebImage.swift
//  Owl
//
//  Created by Denys Danyliuk on 26.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhotoWebImage: View {

    static let thumbnailSize = CGSize(width: 100 * scale, height: 100 * scale)
    static let thumbnailContext: [SDWebImageContextOption: Any] = [
        .imageThumbnailPixelSize: PhotoWebImage.thumbnailSize
    ]

    var photo: Photo?
    var placeholderName: String?
    var isThumbnail: Bool

    var body: some View {
        Group {
            switch photo {
            case let .url(url):
                WebImage(
                    url: url,
                    context: isThumbnail ? PhotoWebImage.thumbnailContext : nil
                )
                .resizable()
                .placeholder(content: {
                    switch isThumbnail {
                    case true:
                        placeholder

                    case false:
                        PhotoWebImage(
                            photo: photo,
                            placeholderName: placeholderName,
                            isThumbnail: true
                        )
                    }
                })
                .scaledToFill()

            case .placeholder:
                placeholder

            case .none:
                Image(uiImage: Asset.Images.gradientOwl.image)
            }
        }
    }

    var placeholder: some View {
        GeometryReader { proxy in
            if let placeholderFirstLater = placeholderName?.first {
                let latin = transliterate(string: String(placeholderFirstLater))
                Image(systemName: "\(latin).circle")
                    .resizable()
                    .scaledToFill()
                    .font(.system(
                        size: 60,
                        weight: proxy.size.height >= 50 ? .ultraLight : .light,
                        design: .rounded
                    ))
                    .background(Color.white)
                    .clipShape(Circle())

            } else {
                Image(uiImage: Asset.Images.gradientOwl.image)
                    .resizable()
                    .scaledToFill()
            }
        }

    }

    func transliterate(string: String) -> String {
        return string
            .applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripDiacritics, reverse: false)?
            .lowercased() ?? string.lowercased()
    }
}

extension PhotoWebImage {

    init(user: User, useResize: Bool) {
        self.photo = user.photo
        self.placeholderName = user.firstName
        self.isThumbnail = useResize
    }
}
