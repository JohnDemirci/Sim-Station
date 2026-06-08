//
//  CreateSimulator+RuntimesView.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//



import SwiftUI

struct CreateSimulatorRuntimeSelectionView: View {
    private let createSimulatorFeature: CreateSimulatorFeature
	private let runtimes: [SimulatorRuntime]

    init(createSimulatorFeature: CreateSimulatorFeature, runtimes: [SimulatorRuntime]) {
        self.createSimulatorFeature = createSimulatorFeature
        self.runtimes = runtimes
    }

	var body: some View {
		VStack(spacing: 24) {
			HeaderView()
			RuntimeSelectionContentView(runtimes: runtimes)
                .environment(createSimulatorFeature)
		}
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			NextButtonToolbarView(createSimulatorFeature: createSimulatorFeature)
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
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature
    private let runtimes: [SimulatorRuntime]

    init(runtimes: [SimulatorRuntime]) {
        self.runtimes = runtimes
    }

	var body: some View {
		VStack(spacing: 16) {
			ContentTitleView()

			VStack(spacing: 8) {
				SelectRuntimePickerView(runtimes: runtimes)
				SelectedRuntimeView()
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
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature
    private let runtimes: [SimulatorRuntime]

    init(runtimes: [SimulatorRuntime]) {
        self.runtimes = runtimes
    }

	var body: some View {
        Picker("Runtime", selection: createSimulatorFeature.binding(\.selectedRuntime) { rt in
            .selectRuntime(rt)
        }) {
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
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		if createSimulatorFeature.selectedRuntime != nil {
			HStack {
				Image(systemName: "checkmark.circle.fill")
					.font(.system(size: 12))
					.foregroundColor(.green)

				Text("Selected: \(createSimulatorFeature.selectedRuntime?.platform ?? "") \(createSimulatorFeature.selectedRuntime?.version ?? "")")
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
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Next") {
                createSimulatorFeature.send(.navigate(.deviceType))
			}
			.buttonStyle(.borderedProminent)
			.disabled(createSimulatorFeature.selectedRuntime == nil)
			.keyboardShortcut(.defaultAction)
		}
	}
}
