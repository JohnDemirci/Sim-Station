//
//  InCaseViewModifier.swift
//  Jodem Sim
//
//  Created by John Demirci on 7/14/25.
//

import SwiftUI

private struct InCaseViewModifier<V: View>: ViewModifier {
    private let `case`: Bool
    @ViewBuilder private let inCaseView: () -> V

    init(
        _ `case`: Bool,
        @ViewBuilder inCaseView: @escaping () -> V
    ) {
        self.case = `case`
        self.inCaseView = inCaseView
    }

    func body(content: Content) -> some View {
        if `case` {
            inCaseView()
        } else {
            content
        }
    }
}

extension View {
    func inCase<V: View>(
        _ case: Bool,
        @ViewBuilder body: @escaping () -> V
    ) -> some View {
        modifier(InCaseViewModifier(`case`, inCaseView: body))
    }
}
