//
//  Sim_StationApp.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SwiftUI
import Supervision

@main
struct Sim_StationApp: App {
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismissWindow) private var closeWindow

    private let container: FeatureContainer<AppEnvironment>
    private let windowSceneFeature: WindowSceneFeature

	init() {
        self.container = FeatureContainer(dependency: AppEnvironment())
        self.windowSceneFeature = container.windowSceneFeature()
	}

    var body: some Scene {
        MenuBarExtra("Sim Station", image: "16x16") {
			MenuBarListView()
				.environment(container)
				.environment(windowSceneFeature)
		}
        .menuBarExtraStyle(.window)

		Group {
			ActiveProcessesScene()
			CreateSimulatorScene()
			BatteryStatusScene()
			SimulatorInformationScene()
		}
		.environment(windowSceneFeature)
		.environment(container)
    }
}

private struct ActiveProcessesScene: Scene {
	@Environment(Container.self) private var container
	@Environment(WindowSceneFeature.self) private var windowSceneFeature

	var body: some Scene {
		WindowGroup(id: .activeProcesses) {
			if let simulatorID = windowSceneFeature.openActiveProcesses.value {
				ActiveProcessesView(simulatorID: simulatorID)
			}
		}
		.manageWindow(windowSceneFeature, keypath: \.openActiveProcesses)
	}
}

private struct BatteryStatusScene: Scene {
	@Environment(Container.self) private var container
    @Environment(WindowSceneFeature.self) private var windowSceneFeature

	var body: some Scene {
		WindowGroup(id: .batteryStatus) {
			if let simulatorID = windowSceneFeature.openBatteryStatus.value {
				BatteryStatusView(simulatorID)
			}
		}
		.manageWindow(windowSceneFeature, keypath: \.openBatteryStatus)
	}
}

private struct CreateSimulatorScene: Scene {
	@Environment(Container.self) private var container
    @Environment(WindowSceneFeature.self) private var windowSceneFeature

	var body: some Scene {
		WindowGroup(id: .createSimulator) {
			if windowSceneFeature.openCreateSimulator.value != nil {
                CreateSimulatorView()
			}
		}
		.manageWindow(windowSceneFeature, keypath: \.openCreateSimulator)
	}
}

private struct SimulatorInformationScene: Scene {
	@Environment(Container.self) private var container
    @Environment(WindowSceneFeature.self) private var windowSceneFeature

	var body: some Scene {
		WindowGroup(id: .simulatorInformation) {
			if let simulator = windowSceneFeature.openSimulatorInformation.value {
				SimulatorInformationView(simulator: simulator)
			}
		}
		.manageWindow(windowSceneFeature, keypath: \.openSimulatorInformation)
	}
}
