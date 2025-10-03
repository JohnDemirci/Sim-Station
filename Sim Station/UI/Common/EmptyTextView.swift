//
//  EmptyTextView.swift
//  Jodem Sim
//
//  Created by John Demirci on 7/14/25.
//

import SwiftUI

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
