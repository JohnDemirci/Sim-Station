//
//  CreateSimulator+SuccessView.swift
//  Sim Station
//
//  Created by John Demirci on 9/11/25.
//

import SSM
import SwiftUI

/// A view that displays the success state after a simulator has been created.
///
/// This view animates a checkmark and reveals details about the created simulator,
/// including device, runtime, and name. It also provides actions to create another simulator
/// or to finish and close the sheet. The content is animated in sequence for a polished user experience.
///
/// - Parameters:
///   - viewStore: The store associated with `CreateSimulatorViewReducer`, used for state and actions.
///   - navigationStore: The store for navigation, allowing control of the sheet presentation.
///
/// The visual flow:
///  1. Shows a progress indicator, then animates to a checkmark.
///  2. Reveals a confirmation message and simulator details.
///  3. Presents buttons for further actions.
struct CreateSimulatorSuccessView: View {
	@State private var successAnimation = false
	@State private var progress: CGFloat = 1.0

	private let createSimulatorStore: CreateSimulatorStore

	init(createSimulatorStore: CreateSimulatorStore) {
		self.createSimulatorStore = createSimulatorStore
	}

	var body: some View {
		VStack(spacing: 32) {
			Spacer()

			VStack(spacing: 24) {
				SuccessAnimationCheckmarkCircle(successAnimation: $successAnimation)
				SimulatorCreationMessageView(successAnimation: $successAnimation)
			}

			PostCreationSimulatorInfoView(
				createSimulatorStore: createSimulatorStore,
				successAnimation: successAnimation
			)

			Spacer()

			PostCreationActionView(
				createSimulatorStore: createSimulatorStore,
				successAnimation: successAnimation
			)
		}
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.task {
			try? await Task.sleep(for: .seconds(0.3))
			withAnimation {
				successAnimation = true
			}
		}
	}
}


/// A view that visually animates the transition from a loading state to a success state with a checkmark.
///
/// - Displays a circular background that animates its color and scale when the `successAnimation` binding becomes `true`.
/// - Initially shows a progress indicator to indicate an ongoing operation.
/// - When the animation is triggered, transitions to displaying a green checkmark inside the circle.
/// - Used as a visual confirmation of a successful operation, typically following an async task.
///
/// - Parameter successAnimation: A binding that controls whether the animation for success is active.
private struct SuccessAnimationCheckmarkCircle: View {
	@Binding var successAnimation: Bool

	var body: some View {
		ZStack {
			Circle()
				.fill(successAnimation ? Color.green.opacity(0.1) : Color.clear)
				.frame(width: 120, height: 120)
				.scaleEffect(successAnimation ? 1.0 : 0.8)
				.animation(.spring(response: 0.6, dampingFraction: 0.8), value: successAnimation)

			Group {
				if successAnimation {
					Image(systemName: "checkmark.circle.fill")
						.font(.system(size: 60, weight: .medium))
						.foregroundColor(.green)
						.scaleEffect(successAnimation ? 1.0 : 0.5)
						.animation(.spring(response: 0.8, dampingFraction: 0.6), value: successAnimation)
				} else {
					ProgressView()
						.progressViewStyle(.circular)
						.controlSize(.large)
						.scaleEffect(1.5)
				}
			}
		}
	}
}

/// A view that displays a message indicating the simulator creation status.
///
/// - Shows a primary message that transitions from "Creating Simulator..." to "Simulator Created!" when the success animation completes.
/// - If the success animation is active, also displays a secondary confirmation message.
/// - Animates message transitions smoothly for a polished user experience.
/// - Used within the simulator creation success sequence.
///
/// - Parameter successAnimation: A binding controlling whether creation has succeeded and the animation should display the success state.
private struct SimulatorCreationMessageView: View {
	@Binding var successAnimation: Bool

	var body: some View {
		VStack(spacing: 8) {
			Text(successAnimation ? "Simulator Created!" : "Creating Simulator...")
				.font(.largeTitle)
				.fontWeight(.semibold)
				.fontDesign(.rounded)
				.opacity(successAnimation ? 1.0 : 0.8)
				.animation(.easeInOut(duration: 0.5), value: successAnimation)

			if successAnimation {
				Text("Your new simulator is ready to use")
					.font(.subheadline)
					.foregroundColor(.secondary)
					.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
	}
}

/// A view that displays simulator details after successful creation.
///
/// - Shows a titled section summarizing the created simulator's device, runtime, and name.
/// - The view is revealed with an animated transition after the success animation completes.
/// - Background and border styling is applied for clarity and separation.
/// - If `successAnimation` is `false`, the view is not shown.
///
/// - Parameters:
///   - viewStore: The store providing access to the selected device, runtime, and name.
///   - successAnimation: Boolean flag indicating whether to show the details with animation.
private struct PostCreationSimulatorInfoView: View {
	let createSimulatorStore: CreateSimulatorStore
	let successAnimation: Bool

	var body: some View {
		VStack(spacing: 16) {
			SimulatorDetailsTitleView()
			SimulatorDetailsView(createSimulatorStore: createSimulatorStore)
		}
		.background(Color(.controlBackgroundColor))
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color(.separatorColor), lineWidth: 1)
		)
		.transition(.move(edge: .bottom).combined(with: .opacity))
		.animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: successAnimation)
		.inCase(!successAnimation) {
			EmptyView()
		}
	}
}

/// A header view for the simulator details section.
///
/// - Displays an info icon and the "Simulator Details" title.
/// - Uses a horizontal layout with spacing and padding for clarity.
/// - Intended to visually separate and label the block of simulator metadata
///   following a successful simulator creation operation.
private struct SimulatorDetailsTitleView: View {
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "info.circle")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.blue)
				.frame(width: 20)

			Text("Simulator Details")
				.font(.headline)
				.foregroundColor(.primary)

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.top, 16)
	}
}

/// A view that displays individual details about the newly created simulator.
///
/// - Shows three rows representing the device, runtime, and name of the created simulator.
/// - Each row displays an icon, a label, and the associated value from the view store.
/// - Used within the post-creation flow to confirm the simulator's parameters to the user.
///
/// - Parameter viewStore: The store providing the current selections for device type, runtime, and simulator name.
private struct SimulatorDetailsView: View {
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		VStack(spacing: 8) {
			SimulatorDetailsRowView(
				icon: "iphone",
				title: "Device",
				value: createSimulatorStore.selectedDeviceType?.name ?? ""
			)

			SimulatorDetailsRowView(
				icon: "gear",
				title: "Runtime",
				value: createSimulatorStore.selectedRuntime?.name ?? ""
			)

			SimulatorDetailsRowView(
				icon: "tag",
				title: "Name",
				value: createSimulatorStore.selectedName
			)
		}
		.padding(.horizontal, 16)
		.padding(.bottom, 16)
	}
}

/// A view that displays a single row of simulator detail information.
///
/// - Presents an SF Symbol icon followed by a title and the corresponding value.
/// - Designed to be used within a list of details, such as device type, runtime, or simulator name.
/// - The icon and title are consistently styled and spaced, and the value is shown with primary emphasis.
///
/// - Parameters:
///   - icon: The name of the SF Symbol to display on the leading edge of the row.
///   - title: The label describing the detail (e.g., "Device", "Runtime").
///   - value: The value corresponding to the detail.
private struct SimulatorDetailsRowView: View {
	let icon: String
	let title: String
	let value: String

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 14))
				.foregroundColor(.secondary)
				.frame(width: 16)

			Text(title)
				.font(.caption)
				.foregroundColor(.secondary)
				.frame(width: 60, alignment: .leading)

			Text(value)
				.font(.body)
				.foregroundColor(.primary)

			Spacer()
		}
	}
}

/// A view that presents post-creation actions after a simulator is successfully created.
///
/// - Shows two prominent buttons: "Create Another Simulator" and "Done".
/// - "Create Another Simulator" resets the simulator creation flow for a new entry.
/// - "Done" dismisses the sheet using the provided navigation store.
/// - Buttons are styled and animated to appear after the success animation completes.
/// - The view uses a transition and appears only when `successAnimation` is `true`.
///
/// - Parameters:
///   - viewStore: Store for sending actions to reset the creation flow.
///   - navigationStore: Store for controlling the dismissal of the containing sheet.
///   - successAnimation: Flag indicating if the success state has been reached (controls reveal).
private struct PostCreationActionView: View {
	@Environment(\.dismissWindow) private var dismissWindow
	let createSimulatorStore: CreateSimulatorStore
	let successAnimation: Bool

	var body: some View {
		VStack(spacing: 12) {
			Button("Create Another Simulator") {
				createSimulatorStore.send(.reset)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
			.frame(maxWidth: .infinity)

			Button("Done") {
				dismissWindow(id: .createSimulator)
			}
			.buttonStyle(.bordered)
			.controlSize(.large)
			.frame(maxWidth: .infinity)
		}
		.transition(.move(edge: .bottom).combined(with: .opacity))
		.animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: successAnimation)
		.inCase(!successAnimation) {
			EmptyView()
		}
	}
}
