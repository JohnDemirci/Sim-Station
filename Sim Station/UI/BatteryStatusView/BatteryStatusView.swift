//
//  BatteryStatusView.swift
//  Sim Station
//
//  Created by John Demirci on 9/11/25.
//

import SwiftUI
import SSM

struct BatteryStatusView: View {
	@Environment(GlobalStore.self) private var globalStore
	let store: BatteryStatusStore

	var body: some View {
		LoadableValueView(
			loadableValue: store.savedState,
			loadedView: { _ in
				BatteryStatusMainView(store: store)
			},
			loadingView: { ProgressView() }
		)
		.task {
			store.send(.retrieveCurrentState)
		}
		.onDisappear {
			globalStore.send(.openBatteryStatus(nil))
		}
	}
}

private struct BatteryStatusMainView: View {
	let store: Store<BatteryStatusReducer>

	var body: some View {
		ScrollView {
			VStack(spacing: 30) {
				HeaderView()
				BatteryVisualizationView(store: store)
				BatteryControlView(store: store)
				UpdateButtonView(store: store)
			}
		}
		.background(
			LinearGradient(
				colors: [Color.clear, Color.gray.opacity(0.1)],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea()
		)
	}
}

private struct HeaderView: View {
	var body: some View {
		VStack(spacing: 8) {
			Text("Battery Status")
				.font(.largeTitle)
				.fontWeight(.bold)
				.foregroundColor(.primary)

			Text("Monitor and adjust your device power")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding(.top, 20)
	}
}

private struct BatteryVisualizationView: View {
	let store: BatteryStatusStore

	var body: some View {
		HStack(spacing: 4) {
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: 6)
					.fill(Color.clear)
					.frame(width: 100, height: 50)

				RoundedRectangle(cornerRadius: 6)
					.stroke(Color.primary, lineWidth: 2.5)
					.frame(width: 100, height: 50)

				RoundedRectangle(cornerRadius: 4)
					.fill(
						LinearGradient(
							colors: [
								store.batteryColor,
								store.batteryColor.opacity(0.7)
							],
							startPoint: .leading,
							endPoint: .trailing
						)
					)
					.frame(
						width: max(4, CGFloat(store.level) * 0.92),
						height: 42
					)
					.offset(x: 4, y: 0)
					.animation(.easeInOut(duration: 0.8), value: store.level)
			}

			// Battery tip
			RoundedRectangle(cornerRadius: 2)
				.fill(Color.primary)
				.frame(width: 4, height: 20)
		}
		.scaleEffect(1.8)
		.padding(.vertical, 20)
	}
}

private struct BatteryControlView: View {
	let store: BatteryStatusStore

	var body: some View {
		VStack(spacing: 20) {
			BatteryLevelControlView(store: store)
			BatteryChargeStateView(currentCharge: store.binding(\.chargeState, default: .unknown))
		}
		.padding()
	}
}

private struct BatteryLevelControlView: View {
	let store: BatteryStatusStore

	var body: some View {
		VStack(spacing: 16) {
			HStack {
				Text("Battery Level")
					.font(.headline)
					.foregroundColor(.primary)
				Spacer()
				Text("\(store.level)%")
					.font(.headline)
					.foregroundColor(.secondary)
					.contentTransition(.numericText())
					.animation(.easeInOut(duration: 0.3), value: store.level)
			}

			ModernSlider(
				value: store.binding(\.level, default: 0),
				initialValue: Double(store.level)
			)
		}
		.padding(20)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(.ultraThinMaterial)
		)
	}
}

struct ModernSlider: View {
	@Binding var value: Int
	@State private var currentValue: Double
	@State private var isDragging = false

	init(
		value: Binding<Int>,
		initialValue: Double
	) {
		self._value = value
		self.currentValue = initialValue
	}

	private var sliderColor: Color {
		switch Int(currentValue) {
		case 0...20: return .red
		case 21...50: return .orange
		case 51...80: return .yellow
		default: return .green
		}
	}

	var body: some View {
		VStack(spacing: 8) {
			Slider(
				value: $currentValue,
				in: ClosedRange(uncheckedBounds: (1, 100)),
				label: {
					Text(value, format: .number)
				},
				onEditingChanged: { isEditing in
					isDragging = isEditing
					if !isEditing {
						value = Int(currentValue)
					}
				}
			)
			.tint(sliderColor)
			.scaleEffect(isDragging ? 1.05 : 1.0)
			.animation(.easeInOut(duration: 0.2), value: isDragging)
		}
	}
}

private struct BatteryChargeStateView: View {
	@Binding var currentCharge: BatteryChargeState

	var body: some View {
		VStack(spacing: 16) {
			HStack {
				Text("Charge State")
					.font(.headline)
					.foregroundColor(.primary)
				Spacer()
			}

			Grid {
				GridRow {
					ForEach(BatteryChargeState.allCases) { state in
						ChargeStateOption(
							state: state,
							isSelected: currentCharge == state
						) {
							withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
								currentCharge = state
							}
						}
						.animation(.spring, value: currentCharge)
					}
				}
			}
		}
		.padding(20)
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(.ultraThinMaterial)
		)
	}
}

private struct ChargeStateOption: View {
	let state: BatteryChargeState
	let isSelected: Bool
	let action: () -> Void

	private var stateIcon: String {
		switch state {
		case .charging: return "bolt.fill"
		case .discharging: return "battery.25"
		case .charged: return "battery.100"
		default: return "unknown"
		}
	}

	private var stateColor: Color {
		switch state {
		case .charging: return .blue
		case .discharging: return .orange
		case .charged: return .green
		default: return .gray
		}
	}

	var body: some View {
		Button(action: action) {
			VStack(spacing: 8) {
				Image(systemName: stateIcon)
					.font(.title2)
					.frame(width: 24, height: 24)
					.foregroundColor(isSelected ? .white : stateColor)

				Text(state.displayName)
					.font(.caption)
					.fontWeight(.medium)
					.foregroundColor(isSelected ? .white : .primary)
			}
			.frame(maxWidth: .infinity)
			.frame(height: 60)
			.padding(.vertical, 10)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(isSelected ? stateColor : Color.gray.opacity(0.1))
			)
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(stateColor, lineWidth: isSelected ? 0 : 1)
			)
			.scaleEffect(isSelected ? 1.05 : 1.0)
		}
		.buttonStyle(PlainButtonStyle())
	}
}

private struct UpdateButtonView: View {
	let store: Store<BatteryStatusReducer>

	var body: some View {
		Button(action: {
			store.send(.setNewBatteryState)
		}) {
			HStack {
				Image(systemName: "arrow.clockwise")
				Text("Update Battery Status")
			}
			.font(.headline)
			.frame(maxWidth: .infinity)
			.padding(.vertical, 16)
			.cornerRadius(12)
			.shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 30)
	}
}

// Extension to provide display names for charge states
extension BatteryChargeState {
	var displayName: String {
		switch self {
		case .charging: return "Charging"
		case .discharging: return "Not Charging"
		case .charged: return "Charged"
		case .unknown: return "Unknown"
		}
	}
}

