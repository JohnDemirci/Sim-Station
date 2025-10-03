
//
//  SimulatorInformationView.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/14/25.
//

import SwiftUI
import AppKit

struct SimulatorInformationView: View {
	@Environment(GlobalStore.self) private var globalStore
	let simulator: Simulator

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				HeaderView(simulator: simulator)
				SimulatorDetailsView(simulator: simulator)

				Spacer()
			}
			.padding(.horizontal, 24)
			.padding(.bottom, 20)
		}
		.frame(minWidth: 400, minHeight: 500)
		.background(Color(NSColor.controlBackgroundColor))
		.onDisappear {
			globalStore.send(.openSimulatorInformation(nil))
		}
	}
}

private struct StatusBadgeView: View {
	let state: Simulator.State?
	let isAvailable: Bool?

	var badgeColor: Color {
		guard let state = state else { return Color(NSColor.tertiaryLabelColor) }

		switch state {
		case .booted:
			return .green
		case .shutdown:
			return .red
		}
	}

	var stateText: String {
		state?.rawValue ?? "Unknown"
	}

	var availabilityText: String {
		isAvailable == true ? "Available" : "Unavailable"
	}

	var availabilityColor: Color {
		isAvailable == true ? .green : .red
	}

	var body: some View {
		HStack {
			Text(stateText)
				.font(.caption)
				.fontWeight(.medium)
				.padding(.horizontal, 10)
				.padding(.vertical, 4)
				.background(badgeColor.opacity(0.15))
				.foregroundColor(badgeColor)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(badgeColor.opacity(0.3), lineWidth: 0.5)
				)
				.clipShape(RoundedRectangle(cornerRadius: 8))

			Text(availabilityText)
				.font(.caption)
				.fontWeight(.medium)
				.padding(.horizontal, 10)
				.padding(.vertical, 4)
				.background(availabilityColor.opacity(0.15))
				.foregroundColor(availabilityColor)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(badgeColor.opacity(0.3), lineWidth: 0.5)
				)
				.clipShape(RoundedRectangle(cornerRadius: 8))
		}
	}
}

private struct InfoRowView: View {
	let icon: String
	let iconColor: Color
	let title: String
	let value: String
	var isCopyable: Bool = false
	var isPath: Bool = false

	@State private var isHovered = false
	@State private var justCopied = false

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			Image(systemName: icon)
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(iconColor)
				.frame(width: 20, height: 20)

			// Content
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.subheadline)
					.fontWeight(.medium)
					.foregroundColor(.secondary)

				if isPath {
					Text(value)
						.font(.system(.body, design: .monospaced))
						.foregroundColor(.primary)
						.textSelection(.enabled)
						.fixedSize(horizontal: false, vertical: true)
				} else {
					Text(value)
						.font(.body)
						.foregroundColor(.primary)
						.textSelection(.enabled)
						.fixedSize(horizontal: false, vertical: true)
				}
			}

			Spacer()

			if isCopyable {
				Button(action: copyToClipboard) {
					Image(systemName: justCopied ? "checkmark" : "doc.on.doc")
						.font(.system(size: 12))
						.foregroundColor(justCopied ? .green : .accentColor)
						.frame(width: 16, height: 16)
				}
				.buttonStyle(PlainButtonStyle())
				.opacity(isHovered ? 1.0 : 0.6)
				.help("Copy to clipboard")
			}
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 16)
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(Color(NSColor.controlBackgroundColor))
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
				)
		)
		.onHover { hovering in
			withAnimation(.easeInOut(duration: 0.2)) {
				isHovered = hovering
			}
		}
	}

	private func copyToClipboard() {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setString(value, forType: .string)

		withAnimation {
			justCopied = true
		}

		Task { @MainActor in
			try? await Task.sleep(for: .seconds(1.5))

			withAnimation {
				justCopied = false
			}
		}
	}
}

private struct HeaderView: View {
	let simulator: Simulator

	var body: some View {
		VStack(spacing: 12) {
			Image(systemName: "iphone")
				.font(.system(size: 48, weight: .light))
				.foregroundColor(.accentColor)

			Text(simulator.name ?? "Unknown Simulator")
				.font(.title2)
				.fontWeight(.medium)
				.multilineTextAlignment(.center)

			StatusBadgeView(state: simulator.state, isAvailable: simulator.isAvailable)
		}
		.padding(.top, 20)
	}
}

private struct SimulatorDetailsView: View {
	let simulator: Simulator

	var body: some View {
		VStack(spacing: 12) {
			InfoRowView(
				icon: "tag",
				iconColor: .purple,
				title: "Identifier",
				value: simulator.id,
				isCopyable: true
			)

			InfoRowView(
				icon: "gear",
				iconColor: .orange,
				title: "Current State",
				value: simulator.state?.rawValue ?? "Unknown"
			)

			InfoRowView(
				icon: "checkmark.shield",
				iconColor: simulator.isAvailable == true ? .green : .red,
				title: "Availability",
				value: simulator.isAvailable == true ? "Available" : "Not Available"
			)

			InfoRowView(
				icon: "desktopcomputer",
				iconColor: .blue,
				title: "Operating System",
				value: simulator.os?.name ?? "Unknown OS"
			)

			InfoRowView(
				icon: "folder",
				iconColor: .secondary,
				title: "Data Location",
				value: simulator.dataPath ?? "Unknown Path",
				isCopyable: true,
				isPath: true
			)
		}
	}
}
