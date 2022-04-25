//
//  ScrollViewDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 25.04.2022.
//

import UIKit
import SwiftUI

struct ScrollViewChanged: Equatable {
    var scrollView: UIScrollView
    var id = UUID()

    static func == (lhs: ScrollViewChanged, rhs: ScrollViewChanged) -> Bool {
        return lhs.id == rhs.id
    }
}

final class ScrollViewDelegate: NSObject, UIScrollViewDelegate, ObservableObject {

    @Published var scrollViewDidScroll: ScrollViewChanged?
    @Published var scrollViewDidEndDragging: ScrollViewChanged?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("-----scrollViewDidScroll\(scrollView.contentOffset.y)")
        scrollViewDidScroll = ScrollViewChanged(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("!!!!!scrollViewDidEndDragging\(scrollView.contentOffset.y)")
        scrollViewDidEndDragging = ScrollViewChanged(scrollView: scrollView)
    }
}
