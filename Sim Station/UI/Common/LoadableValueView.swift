//
//  LoadableValueView.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/23/25.
//

import SwiftUI
import LoadableValues

struct LoadableValueView<
    ErrorView: View,
    Failure: Error,
    IdleView: View,
    LoadedView: View,
    LoadingView: View,
    Value: Sendable
>: View {
    private let errorView: (Failure) -> ErrorView
    private let idleView: () -> IdleView
    private let loadableValue: LoadableValue<Value, Failure>
    private let loadedView: (Value) -> LoadedView
    private let loadingView: () -> LoadingView

    /**
     Initializes a `LoadableValueView`, which displays different views based on the loading state of a value.
     
     - Parameters:
       - loadableValue: The `LoadableValue` object indicating the current loading state and value or error, if any.
       - errorView: A closure that returns a view to display when loading has failed.
       - idleView: A closure that returns a view to display when the view is idle (i.e., before loading begins).
       - loadedView: A closure that returns a view to display when the value has successfully loaded.
       - loadingView: A closure that returns a view to display while the value is loading.
     */
    init(
        loadableValue: LoadableValue<Value, Failure>,
        @ViewBuilder errorView: @escaping (Failure) -> ErrorView,
        @ViewBuilder idleView: @escaping () -> IdleView,
        @ViewBuilder loadedView: @escaping (Value) -> LoadedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self.errorView = errorView
        self.idleView = idleView
        self.loadableValue = loadableValue
        self.loadedView = loadedView
        self.loadingView = loadingView
    }

    var body: some View {
        switch loadableValue {
        case .failed(let error):
            errorView(error.failure)
                .transition(.opacity)

        case .idle, .cancelled:
            idleView()
                .transition(.opacity)

        case .loaded(let value):
            loadedView(value.value)
                .transition(.opacity)

        case .loading:
            loadingView()
                .transition(.identity)
        }
    }
}

extension LoadableValueView where IdleView == EmptyTextView, ErrorView == EmptyTextView {
    /**
     Initializes a `LoadableValueView` that only displays loaded and loading views.

     This initializer is used when idle and error views are not needed; those states will display as empty.

     - Parameters:
       - loadableValue: The `LoadableValue` object indicating the current state and value or error, if any.
       - loadedView: A closure that returns a view to display when the value has successfully loaded.
       - loadingView: A closure that returns a view to display while the value is loading.
     */
    init(
        loadableValue: LoadableValue<Value, Failure>,
        @ViewBuilder loadedView: @escaping (Value) -> LoadedView,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self.loadableValue = loadableValue
        self.loadedView = loadedView
        self.loadingView = loadingView
        self.errorView = { _ in EmptyTextView() }
        self.idleView = { EmptyTextView() }
    }
}
