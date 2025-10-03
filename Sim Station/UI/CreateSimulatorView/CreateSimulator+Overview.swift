//
//  CreateSimulator+Overview.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//

import SSM
import SwiftUI

struct CreateSimulatorOverviewView: View {
	private let createSimulatorStore: CreateSimulatorStore

	init(createSimulatorStore: CreateSimulatorStore) {
		self.createSimulatorStore = createSimulatorStore
	}

	var body: some View {
		VStack(spacing: 24) {
			HeaderView(createSimulatorStore: createSimulatorStore)
			SelectionDetailsView(createSimulatorStore: createSimulatorStore)
			Spacer()
		}
		.padding(.horizontal, 32)
		.padding(.vertical, 24)
		.toolbar {
			PreviousButtonToolbarView(createSimulatorStore: createSimulatorStore)
			CreateSimulatorButtonToolbarView(createSimulatorStore: createSimulatorStore)
		}
	}
}


private struct HeaderView: View {
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: createSimulatorStore.iconSystemImage)
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
	let createSimulatorStore: CreateSimulatorStore

	var body: some View {
		VStack(spacing: 0) {
			SelectionRowView(
				systemImage: createSimulatorStore.iconSystemImage,
				title: "Device Model",
				description: createSimulatorStore.selectedDeviceType?.name ?? "",
				color: .blue
			)

			Divider()
				.padding(.horizontal, 16)

			SelectionRowView(
				systemImage: "gear",
				title: "Runtime",
				description: createSimulatorStore.selectedRuntime?.name ?? "",
				color: .green
			)

			Divider()
				.padding(.horizontal, 16)

			SelectionRowView(
				systemImage: "tag",
				title: "Name",
				description: createSimulatorStore.selectedName,
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
	let createSimulatorStore: CreateSimulatorStore

	var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button("Previous") {
				createSimulatorStore.send(.navigate(.nameSelection))
			}
			.keyboardShortcut(.cancelAction)
		}
	}
}

private struct CreateSimulatorButtonToolbarView: ToolbarContent {
	let createSimulatorStore: CreateSimulatorStore

	var body: some ToolbarContent {
		ToolbarItem(placement: .confirmationAction) {
			Button("Create Simulator") {
				createSimulatorStore.send(.createSimulator)
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
