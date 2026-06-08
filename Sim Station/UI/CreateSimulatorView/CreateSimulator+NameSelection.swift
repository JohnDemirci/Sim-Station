//
//  CreateSimulator+NameSelection.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//



import SwiftUI

struct SimulatorNameSelectionView: View {
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some View {
		VStack(spacing: 24) {
			HeaderView()
			SimulatorNameSelectionMainContentView()
			SimulatorNameSuggestionView()
		}
        .environment(createSimulatorFeature)
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			PreviousButtonToolbarView(createSimulatorFeature: createSimulatorFeature)
			NextButtonToolbarView(createSimulatorFeature: createSimulatorFeature)
		}
	}
}


private struct HeaderView: View {
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: "tag.circle")
				.font(.system(size: 40))
				.foregroundColor(.orange)

			Text("Name Your Simulator")
				.font(.largeTitle)
				.fontWeight(.semibold)
				.fontDesign(.rounded)

			Text("Give your simulator a memorable name")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding(.top, 20)
	}
}


private struct SimulatorNameSelectionMainContentView: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		VStack(spacing: 16) {
			ContentTitleView()

			VStack(spacing: 8) {
				SimulatorSelectionTextField()
			}
			.padding(.bottom, 16)
		}
		.background(Color(.controlBackgroundColor))
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color(.separatorColor), lineWidth: 1)
		)
	}
}

private struct ContentTitleView: View {
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "tag")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.orange)
				.frame(width: 20)

			Text("Simulator Name")
				.font(.headline)
				.foregroundColor(.primary)

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.top, 16)
	}
}

private struct SimulatorSelectionTextField: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature
	@FocusState private var isTextFieldFocused: Bool

	var body: some View {
        TextField("Enter simulator name...", text: createSimulatorFeature.binding(\.selectedName) { name in
            .selectName(name)
        })
        .textFieldStyle(.plain)
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.textBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isTextFieldFocused ? Color.orange : Color(.separatorColor),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .focused($isTextFieldFocused)
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation { isTextFieldFocused = true }
        }
    }
}

private struct ValidSimulatorNameDisplayView: View {
	var body: some View {
		HStack {
			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: 12))
				.foregroundColor(.green)

			Text("Name looks good!")
				.font(.caption)
				.foregroundColor(.secondary)

			Spacer()
		}
	}
}

private struct InvalidSimulatorNameDisplayView: View {
	var body: some View {
		HStack {
			Image(systemName: "xmark")
				.font(.system(size: 12))
				.foregroundColor(.red)

			Text("This simulator name already exists")
				.font(.caption)
				.foregroundColor(.secondary)

			Spacer()
		}
	}
}


/// A view that displays suggested names for the simulator during the name entry step of the creation flow.
///
/// - Purpose:
///   Presents a set of contextual name suggestions to help users quickly choose a suitable simulator name,
///   especially when the name text field is currently empty.
///
/// - Features:
///   - Appears only when the user has not yet entered a name.
///   - Shows a "Suggestions" label and a grid of suggested names as small bordered buttons.
///   - Tapping a suggestion sends an action to update the simulator name with the chosen suggestion.
///
/// - Layout:
///   - A vertical stack containing:
///     - A header ("Suggestions" caption) aligned to the leading edge.
///     - A two-column grid displaying up to four suggested names as buttons.
///
/// - Suggestion Generation:
///   - Suggestions are derived from the current device type and runtime selected in the view store's state.
///   - Only suggestions with a length of 25 characters or fewer are shown to fit the UI.
///
/// - Parameters:
///   - viewStore: The store providing access to current selection state and enabling updates on suggestion tap.
///
/// - Usage:
///   - Used within the simulator creation flow, beneath the name entry field,
///     to offer user-friendly, context-aware naming options.
private struct SimulatorNameSuggestionView: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		if createSimulatorFeature.selectedName.isEmpty {
			VStack(spacing: 8) {
				HStack {
					Text("Suggestions")
						.font(.caption)
						.foregroundColor(.secondary)

					Spacer()
				}

				VStack {
					ForEach(nameSuggestions(), id: \.self) { suggestion in
						Button(suggestion) {
                            createSimulatorFeature.send(.selectName(suggestion))
						}
						.buttonStyle(.bordered)
						.controlSize(.small)
					}
				}
				.frame(maxWidth: .infinity)
			}
			.padding(.horizontal, 4)
		}
	}

	private func nameSuggestions() -> [String] {
		let deviceName = createSimulatorFeature.selectedDeviceType?.name ?? ""
		let runtimeName = createSimulatorFeature.selectedRuntime?.name ?? ""

		return [
			"My \(deviceName)",
			"\(deviceName) Test",
			"Development \(deviceName)",
			"\(runtimeName) Simulator",
			"Simulator \(Int.random(in: 0..<10000))"
		].compactMap { suggestion in
			// Only show suggestions that aren't too long
			suggestion.count <= 25 ? suggestion : nil
		}
	}
}



private struct PreviousButtonToolbarView: ToolbarContent {
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button("Previous") {
                createSimulatorFeature.send(.navigate(.deviceType))
			}
			.keyboardShortcut(.cancelAction)
		}
	}
}

private struct NextButtonToolbarView: ToolbarContent {
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Next") {
                createSimulatorFeature.send(.navigate(.overview))
			}
			.buttonStyle(.borderedProminent)
			.disabled(isButtonDisabled)
			.keyboardShortcut(.defaultAction)
		}
	}

	var isButtonDisabled: Bool {
        createSimulatorFeature.selectedName.isEmpty
	}
}
