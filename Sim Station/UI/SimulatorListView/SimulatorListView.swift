//
//  SimulatorListView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import OrderedCollections
import SSM
import SwiftUI

typealias Container = StoreContrainer<AppEnvironment>
typealias InstalledAppsStore = Store<InstalledApplicationsReducer>

struct SimulatorListLoadableView: View {
	@Environment(Container.self) private var container
	private let simulatorStore: SimulatorStore

	init(simulatorStore: SimulatorStore) {
		self.simulatorStore = simulatorStore
	}

	var body: some View {
		LoadableValueView(
			loadableValue: simulatorStore.simulators,
			loadedView: { loadedSimulators in
				OSMenuListView(simulators: loadedSimulators)
					.environment(simulatorStore)
					.environment(container)
			},
			loadingView: { ProgressView() }
		)
		.onAppear {
			simulatorStore.send(.retrieveSimulators)
		}
	}
}

private struct OSMenuListView: View {
	let simulators: OrderedDictionary<OS.Name, [Simulator]>
	var body: some View {
		ForEach(simulators.keys) { key in
			Menu {
				SimulatorListMenuViewView(simulators: simulators[key] ?? [])
			} label: {
				Text(key.name)
					.font(.title3)
			}
		}
	}
}

private struct SimulatorListMenuViewView: View {
	@Environment(Container.self) private var container
	@Environment(\.openWindow) private var openWindow
	let simulators: [Simulator]

	var body: some View {
		ForEach(simulators) { simulator in
			Menu {
				SimulatorStateToggleView(simulator: simulator)
				ActiveProcessesButton(simulator: simulator)
				DocumentsFolderButtonView(simulator: simulator)
				SimulatorInformationViewButton(simulator: simulator)
				InstalledApplicationsMenuView(
					installedAppsStore: container.installedAppsStore(simulator.id),
					simulator: simulator
				)
				DeleteSimulatorButtonView(simulator: simulator)
				ModifyBatteryStatusView(simulator: simulator)
			} label: {
				Text(simulatorNameAttributedString(simulator))
					.font(.title3)
			}
		}
	}

	func simulatorNameAttributedString(_ simulator: Simulator) -> AttributedString {
		let initial = AttributedString(simulator.name ?? "")
		let status: AttributedString = switch simulator.state {
		case .booted:
			AttributedString("🟢")
		case .shutdown, .none:
			AttributedString("⚪️")
		}

		return status + " " + initial
	}
}

private struct SimulatorStateToggleView: View {
	let simulator: Simulator
	var body: some View {
		switch simulator.state {
		case .booted:
			ShutdownSimulatorView(simulator: simulator)
		case .shutdown, .none:
			BootSimulatorView(simulator: simulator)
		}
	}
}

private struct ActiveProcessesButton: View {
	@Environment(GlobalStore.self) private var globalStore
	let simulator: Simulator

	var body: some View {
		Button("Active Processes") {
			globalStore.send(.openActiveProcesses(simulator.id))
		}
		.disabled(isDisabled)
		.help("Simulator needs to be booted in order to see the active processes")
	}

	var isDisabled: Bool {
		switch simulator.state {
		case .shutdown, .none:
			return true
		case .booted:
			return false
		}
	}
}

private struct BootSimulatorView: View {
	@Environment(SimulatorStore.self) private var simulatorStore
	let simulator: Simulator

	var body: some View {
		Button("Boot") {
			simulatorStore.send(.updateSimulatorState(simulator, .booted))
		}
	}
}

private struct DeleteSimulatorButtonView: View {
	@Environment(SimulatorStore.self) private var simulatorStore
	let simulator: Simulator
	var body: some View {
		Button("Delete") {
			simulatorStore.send(.deleteSimulator(simulator))
		}
		.tint(.red)
	}
}

private struct DocumentsFolderButtonView: View {
	let simulator: Simulator

	var body: some View {
		Button("Documents") {
			guard let path = simulator.dataPath else { return }
			let url = URL(fileURLWithPath: path)
			NSWorkspace.shared.open(url)
		}
	}
}

private struct InstalledApplicationsMenuView: View {
	let installedAppsStore: InstalledAppsStore
	let simulator: Simulator

	var body: some View {
		Menu("Installed Applications") {
			LoadableValueView(
				loadableValue: installedAppsStore.applications,
				loadedView: { (applications: [Simulator.Application]) in
					InstalledApplicationsView(
						applications: applications,
						installedAppsStore: installedAppsStore
					)
				},
				loadingView: { ProgressView() }
			)
		}
		.onAppear {
			installedAppsStore.send(.retrieve)
		}
		.inCase(simulator.state != .booted) {
			Text("Installed Applications")
				.help("Boot the simulator to see the installed applciations")
		}
	}
}

private struct SimulatorInformationViewButton: View {
	@Environment(GlobalStore.self) private var globalStore
	let simulator: Simulator

	var body: some View {
		Button("Information") {
			globalStore.send(.openSimulatorInformation(simulator))
		}
	}
}

private struct ModifyBatteryStatusView: View {
	@Environment(GlobalStore.self) private var globalStore
	let simulator: Simulator

	var body: some View {
		Button("Modify Battery Status") {
			globalStore.send(.openBatteryStatus(simulator.id))
		}
		.disabled(isDisabled)
		.help("Simulator needs to be booted in order to see the active processes")
	}

	var isDisabled: Bool {
		switch simulator.state {
		case .shutdown, .none:
			return true
		case .booted:
			return false
		}
	}
}

private struct ShutdownSimulatorView: View {
	@Environment(SimulatorStore.self) private var simulatorStore
	let simulator: Simulator

	var body: some View {
		Button("Shutdown") {
			simulatorStore.send(.updateSimulatorState(simulator, .shutdown))
		}
	}
}

private struct InstalledApplicationsView: View {
	let applications: [Simulator.Application]
	let installedAppsStore: InstalledAppsStore

	var body: some View {
		ForEach(applications) { application in
			Menu(application.CFBundleDisplayName) {
				Button("Application Data") {
					installedAppsStore.send(.openApplicationDataFolder(application))
				}

				Button("Open User Defaults") {
					installedAppsStore.send(.openUserDefaults(application))
				}
			}
		}
	}
}
