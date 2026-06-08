//
//  CreateSimulator+Overview.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//


import SwiftUI

struct CreateSimulatorOverviewView: View {
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some View {
		VStack(spacing: 24) {
			HeaderView()
			SelectionDetailsView()
			Spacer()
		}
        .environment(createSimulatorFeature)
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			PreviousButtonToolbarView(createSimulatorFeature: createSimulatorFeature)
			CreateSimulatorButtonToolbarView(createSimulatorFeature: createSimulatorFeature)
		}
	}
}


private struct HeaderView: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: createSimulatorFeature.iconSystemImage)
				.font(.system(size: 40))
				.foregroundColor(.accentColor)

			Text("Review & Create")
				.font(.largeTitle)
				.fontWeight(.semibold)
				.fontDesign(.rounded)

			Text("Review your simulator configuration before creating")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding(.top, 20)
	}
}

private struct SelectionDetailsView: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		VStack(spacing: 0) {
			SelectionRowView(
				systemImage: createSimulatorFeature.iconSystemImage,
				title: "Device Model",
				description: createSimulatorFeature.selectedDeviceType?.name ?? "",
				color: .blue
			)

			Divider()
				.padding(.horizontal, 16)

			SelectionRowView(
				systemImage: "gear",
				title: "Runtime",
				description: createSimulatorFeature.selectedRuntime?.name ?? "",
				color: .green
			)

			Divider()
				.padding(.horizontal, 16)

			SelectionRowView(
				systemImage: "tag",
				title: "Name",
				description: createSimulatorFeature.selectedName,
				color: .orange
			)
		}
		.background(Color(.controlBackgroundColor))
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay(
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color(.separatorColor), lineWidth: 1)
		)
	}
}

private struct SelectionRowView: View {
	let systemImage: String
	let title: String
	let description: String
	let color: Color

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: systemImage)
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(color)
				.frame(width: 20)

			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.headline)
					.foregroundColor(.primary)

				Text(description)
					.font(.body)
					.foregroundColor(.secondary)
					.lineLimit(1)
			}

			Spacer()
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 12)
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
				createSimulatorFeature.send(.navigate(.nameSelection))
			}
			.keyboardShortcut(.cancelAction)
		}
	}
}

private struct CreateSimulatorButtonToolbarView: ToolbarContent {
    private let createSimulatorFeature: CreateSimulatorFeature

    init(createSimulatorFeature: CreateSimulatorFeature) {
        self.createSimulatorFeature = createSimulatorFeature
    }

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Create Simulator") {
				createSimulatorFeature.send(.createSimulator)
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
