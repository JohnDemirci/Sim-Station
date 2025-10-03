//
//  Sim_StationApp.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM
import SwiftUI

@main
struct Sim_StationApp: App {
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismissWindow) private var closeWindow

	let container: StoreContrainer<AppEnvironment>
	let globalStore: Store<GlobalReducer>

	init() {
		self.container = StoreContrainer(environment: AppEnvironment())
		self.globalStore = self.container.globalStore()
	}

    var body: some Scene {
		MenuBarExtra("Sim Station", systemImage: "train.side.front.car") {
			MenuBarListView()
				.environment(container)
				.environment(globalStore)
		}

		Group {
			ActiveProcessesScene()
			CreateSimulatorScene()
			BatteryStatusScene()
			SimulatorInformationScene()
		}
		.environment(globalStore)
		.environment(container)
    }
}

private struct ActiveProcessesScene: Scene {
	@Environment(Container.self) private var container
	@Environment(GlobalStore.self) private var globalStore

	var body: some Scene {
		WindowGroup(id: .activeProcesses) {
			if let simulatorID = globalStore.openActiveProcesses.value {
				ActiveProcessesLoadableView(
					activeProcessesStore: container.activeProcessesStore(simulatorID)
				)
			}
		}
		.manageWindow(globalStore, keypath: \.openActiveProcesses)
	}
}

private struct BatteryStatusScene: Scene {
	@Environment(Container.self) private var container
	@Environment(GlobalStore.self) private var globalStore

	var body: some Scene {
		WindowGroup(id: .batteryStatus) {
			if let simulatorID = globalStore.openBatteryStatus.value {
				BatteryStatusView(store: container.batteryStatusStore(simulatorID))
			}
		}
		.manageWindow(globalStore, keypath: \.openBatteryStatus)
	}
}

private struct CreateSimulatorScene: Scene {
	@Environment(Container.self) private var container
	@Environment(GlobalStore.self) private var globalStore

	var body: some Scene {
		WindowGroup(id: .createSimulator) {
			if globalStore.openCreateSimulator.value != nil {
				CreateSimulatorLoadableView(createSimulatorStore: container.createSimulatorStore())
			}
		}
		.manageWindow(globalStore, keypath: \.openCreateSimulator)
	}
}

private struct SimulatorInformationScene: Scene {
	@Environment(Container.self) private var container
	@Environment(GlobalStore.self) private var globalStore

	var body: some Scene {
		WindowGroup(id: .simulatorInformation) {
			if let simulator = globalStore.openSimulatorInformation.value {
				SimulatorInformationView(simulator: simulator)
			}
		}
		.manageWindow(globalStore, keypath: \.openSimulatorInformation)
	}
}
