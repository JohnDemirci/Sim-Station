//
//  CreateSimulator+DeviceTypeView.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//

import SwiftUI

struct CreateSimulatorDeviceTypesView: View {
	let createSimulatorStore: CreateSimulatorStore
	let deviceTypes: [DeviceType]

	var body: some View {
		VStack(spacing: 24) {
			HeaderView(createSimulatorStore: createSimulatorStore)
			DeviceModelSelectionContentView(
				createSimulatorStore: createSimulatorStore,
				deviceTypes: deviceTypes
			)
		}
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			PreviousButtonToolbarView(createSimulatorStore: createSimulatorStore)
			NextButtonToolbarView(createSimulatorStore: createSimulatorStore)
		}
	}
}

private struct HeaderView: View {
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		VStack(spacing: 8) {
			HeaderViewIconView(createSimulatorStore: createSimulatorStore)

			Text("Select Device Model")
				.font(.largeTitle)
				.fontWeight(.semibold)
				.fontDesign(.rounded)

			Text("Choose the device type for your new simulator")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding(.top, 20)
	}
}

private struct HeaderViewIconView: View {
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		Image(systemName: createSimulatorStore.iconSystemImage)
			.font(.system(size: 40))
			.foregroundColor(.blue)
			.animation(.spring, value: createSimulatorStore.iconSystemImage)
			.transition(.scale)
	}
}

/// A view presenting the main content for selecting a device model in the simulator creation flow.
///
/// `DeviceModelSelectionContentView` displays:
/// - A content title header clarifying the purpose of the selection area.
/// - A menu-based picker (`ContentPickerView`) populated with available device types, allowing the user to choose one.
/// - A contextual display (`SelectedDeviceTypeView`) showing the currently selected device type (if any).
///
/// The view visually groups these elements within a styled card-like section, using a rounded rectangle background and a border,
/// enhancing clarity and separation from the rest of the UI.
///
/// - Parameters:
///   - deviceTypes: The list of device types (as strings) available for selection.
///   - viewStore: A store managing the state and actions for the simulator creation process (via `CreateSimulatorViewReducer`).
private struct DeviceModelSelectionContentView: View {
	let createSimulatorStore: CreateSimulatorStore
	let deviceTypes: [DeviceType]

	var body: some View {
		VStack(spacing: 16) {
			ContentTitleView()

			VStack(spacing: 8) {
				ContentPickerView(
					createSimulatorStore: createSimulatorStore,
					deviceTypes: deviceTypes
				)

				SelectedDeviceTypeView(createSimulatorStore: createSimulatorStore)
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

/// A view that displays the header for the device model selection section.
///
/// `ContentTitleView` appears at the top of the device model selection card,
/// showing an icon and a title ("Device Model") to clearly label the content area.
/// The layout includes:
/// - An icon representing a collection of devices (using the "square.stack.3d.up" SF Symbol).
/// - The section title.
/// - A spacer to align content to the leading edge.
///
/// This view is typically used within a visually grouped card to clarify the
/// current selection context in the simulator creation flow.
private struct ContentTitleView: View {
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "square.stack.3d.up")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.blue)
				.frame(width: 20)

			Text("Device Model")
				.font(.headline)
				.foregroundColor(.primary)

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.top, 16)
	}
}

/// A view that presents a menu-style picker for selecting a device model during simulator creation.
///
/// `ContentPickerView` displays a SwiftUI `Picker` populated with the available device types provided in `deviceTypes`.
/// The currently selected device type is managed by the `viewStore`, which binds the selection to its state (`selectedDeviceType`).
/// Device model names are formatted for display using a helper on the reducer's state.
///
/// - Parameters:
///   - deviceTypes: An array of device type identifiers presented as selectable options.
///   - viewStore: A store managing the state and actions for the simulator creation flow, including the selected device type.
///
/// The picker uses a `.menu` style and expands to fill the horizontal space of its container.
private struct ContentPickerView: View {
	let createSimulatorStore: CreateSimulatorStore
	let deviceTypes: [DeviceType]

	var body: some View {
		Picker("Device Model", selection: createSimulatorStore.binding(\.selectedDeviceType)) {
			ForEach(deviceTypes, id: \.self) { deviceType in
				Text(deviceType.name)
					.tag(deviceType)
			}
		}
		.pickerStyle(.menu)
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 16)
	}
}


/// A view that displays the currently selected device type in the simulator creation flow.
///
/// `SelectedDeviceTypeView` provides a compact visual confirmation of the user's selection:
/// - Shows a green checkmark icon alongside a caption describing the selected device model.
/// - Only appears if a device type is currently selected (`selectedDeviceType` is not empty).
///
/// This view is intended for use within the device model selection UI, helping users
/// confirm their choice before proceeding. It fetches the display name for the selected
/// device model from the reducer's formatting helper.
///
/// - Parameter viewStore: A store providing access to the selection state and formatting logic.
private struct SelectedDeviceTypeView: View {
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		HStack {
			Image(systemName: "checkmark.circle.fill")
				.font(.system(size: 12))
				.foregroundColor(.green)

			Text("Selected: \(createSimulatorStore.selectedDeviceType?.name ?? "")")
				.font(.caption)
				.foregroundColor(.secondary)

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.bottom, 8)
		.inCase(createSimulatorStore.selectedDeviceType != nil) {
			EmptyView()
		}
	}
}

private struct PreviousButtonToolbarView: ToolbarContent {
	let createSimulatorStore: CreateSimulatorStore

	var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button("Previous") {
				createSimulatorStore.send(.navigate(.runtimes))
			}
			.buttonStyle(.borderedProminent)
			.keyboardShortcut(.cancelAction)
		}
	}
}

private struct NextButtonToolbarView: ToolbarContent {
	let createSimulatorStore: CreateSimulatorStore

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Next") {
				createSimulatorStore.send(.navigate(.nameSelection))
			}
			.buttonStyle(.borderedProminent)
			.disabled(createSimulatorStore.selectedDeviceType == nil)
			.keyboardShortcut(.defaultAction)
		}
	}
}
