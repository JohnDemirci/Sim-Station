//
//  EmptyTextView.swift
//  Jodem Sim
//
//  Created by John Demirci on 7/14/25.
//

import SwiftUI

/// Sometimes, instead of using EmptyView, an Empty Text Could be used if appropriate.
struct EmptyTextView: View {
    var body: some View {
        Text()
    }
}

extension Text {
    init() {
        self = Text("")
    }
}
