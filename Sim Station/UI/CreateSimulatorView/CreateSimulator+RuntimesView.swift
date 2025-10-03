//
//  CreateSimulator+RuntimesView.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//


import SSM
import SwiftUI

struct CreateSimulatorRuntimeSelectionView: View {
	let createSimulatorStore: CreateSimulatorStore
	let runtimes: [SimulatorRuntime]

	var body: some View {
		VStack(spacing: 24) {
			HeaderView()
			RuntimeSelectionContentView(
				createSimulatorStore: createSimulatorStore,
				runtimes: runtimes
			)
		}
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			NextButtonToolbarView(createSimulatorStore: createSimulatorStore)
		}
	}
}

private struct HeaderView: View {
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: "gear.circle")
				.font(.system(size: 40))
				.foregroundColor(.green)

			Text("Select Runtime")
				.font(.largeTitle)
				.fontWeight(.semibold)
				.fontDesign(.rounded)

			Text("Choose the iOS version for your simulator")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding(.top, 20)
	}
}

private struct RuntimeSelectionContentView: View {
	let createSimulatorStore: CreateSimulatorStore
	let runtimes: [SimulatorRuntime]

	var body: some View {
		VStack(spacing: 16) {
			ContentTitleView()

			VStack(spacing: 8) {
				SelectRuntimePickerView(
					createSimulatorStore: createSimulatorStore,
					runtimes: runtimes
				)
				SelectedRuntimeView(createSimulatorStore: createSimulatorStore)
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
			Image(systemName: "gear")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.green)
				.frame(width: 20)

			Text("Runtime")
				.font(.headline)
				.foregroundColor(.primary)

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.top, 16)
	}
}

private struct SelectRuntimePickerView: View {
	let createSimulatorStore: CreateSimulatorStore
	let runtimes: [SimulatorRuntime]

	var body: some View {
		Picker("Runtime", selection: createSimulatorStore.binding(\.selectedRuntime)) {
			ForEach(runtimes, id: \.self) { runtime in
				Text(runtime.name)
					.tag(runtime)
			}
		}
		.pickerStyle(.menu)
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 16)
	}
}

private struct SelectedRuntimeView: View {
	let createSimulatorStore: CreateSimulatorStore
	var body: some View {
		if createSimulatorStore.selectedRuntime != nil {
			HStack {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 12))
					.foregroundColor(.green)

				Text("Selected: \(createSimulatorStore.selectedRuntime?.platform ?? "") \(createSimulatorStore.selectedRuntime?.version ?? "")")
					.font(.caption)
					.foregroundColor(.secondary)

				Spacer()
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 8)
		}
	}
}

private struct NextButtonToolbarView: ToolbarContent {
	let createSimulatorStore: CreateSimulatorStore

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Next") {
				createSimulatorStore.send(.navigate(.deviceType))
			}
			.buttonStyle(.borderedProminent)
			.disabled(createSimulatorStore.selectedRuntime == nil)
			.keyboardShortcut(.defaultAction)
		}
	}
}
