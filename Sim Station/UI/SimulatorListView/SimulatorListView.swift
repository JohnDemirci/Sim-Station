//
//  SimulatorListView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Combine
import OrderedCollections
import SwiftUI
import Supervision
import LoadableValue

typealias Container = FeatureContainer<AppEnvironment>

struct SimulatorListLoadableView: View {
	@Environment(Container.self) private var container
    private let simulatorFeature: SimulatorFeature

    init(simulatorFeature: SimulatorFeature) {
        self.simulatorFeature = simulatorFeature
	}

	var body: some View {
		LoadableValueView(
            simulatorFeature.simulators,
            loaded: { loadedSimulators in
                OSMenuListView(simulators: loadedSimulators)
                    .environment(simulatorFeature)
                    .environment(container)
            },
            failed: { _ in ProgressView() }
		)
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
            .padding()
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
				InstalledApplicationsView(simulator: simulator)
				DeleteSimulatorButtonView(simulator: simulator)
				ModifyBatteryStatusView(simulator: simulator)
			} label: {
				Text(simulatorNameAttributedString(simulator))
					.font(.title3)
			}
		}
	}

	func simulatorNameAttributedString(_ simulator: Simulator) -> AttributedString {
		let simulatorName = AttributedString(simulator.name ?? "")
		let simulatorStatus: AttributedString = switch simulator.state {
		case .booted:
			AttributedString("🟢")
		case .shutdown, .none:
			AttributedString("⚪️")
		}

		return simulatorStatus + " " + simulatorName
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
	@Environment(WindowSceneFeature.self) private var windowSceneFeature
	let simulator: Simulator

	var body: some View {
		Button("Active Processes") {
			windowSceneFeature.send(.openActiveProcesses(simulator.id))
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
    @Environment(SimulatorFeature.self) private var simulatorFeature
	let simulator: Simulator

	var body: some View {
		Button("Boot") {
			simulatorFeature.send(.updateSimulatorState(simulator, .booted))
		}
	}
}

private struct DeleteSimulatorButtonView: View {
	@Environment(SimulatorFeature.self) private var simulatorFeature
	let simulator: Simulator
	var body: some View {
		Button("Delete") {
			simulatorFeature.send(.deleteSimulator(simulator))
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

private struct InstalledApplicationsView: View {
    @Environment(Container.self) private var container
    @State private var installedApplicationsFeatureState: InstalledApplicationsFeatureState = .idle
    private let simulator: Simulator

    init(simulator: Simulator) {
        self.simulator = simulator
    }

    var body: some View {
        FeatureStateView(state: $installedApplicationsFeatureState) { feature in
            InstalledApplicationsMenuView(simulator: simulator)
                .environment(feature)
        }
        .instantiate(with: container.installedApplications(simulator.id))
    }
}

private struct InstalledApplicationsMenuView: View {
    @Environment(InstalledApplicationsFeature.self) private var installedApplicationsFeature
	let simulator: Simulator

	var body: some View {
		Menu("Installed Applications") {
			LoadableValueView(
                installedApplicationsFeature.applications,
                loaded: { (applications: [Simulator.Application]) in
                    InstalledApplicationsForEachView(applications: applications)
                },
                failed: { _ in ProgressView() }
			)
		}
		.onAppear {
			installedApplicationsFeature.send(.retrieveInstalledApplications)
		}
		.inCase(simulator.state != .booted) {
			Text("Installed Applications")
				.help("Boot the simulator to see the installed applciations")
		}
	}
}

private struct SimulatorInformationViewButton: View {
	@Environment(WindowSceneFeature.self) private var windowSceneFeature
	let simulator: Simulator

	var body: some View {
		Button("Information") {
			windowSceneFeature.send(.openSimulatorInformation(simulator))
		}
	}
}

private struct ModifyBatteryStatusView: View {
	@Environment(WindowSceneFeature.self) private var windowSceneFeature
	let simulator: Simulator

	var body: some View {
		Button("Modify Battery Status") {
			windowSceneFeature.send(.openBatteryStatus(simulator.id))
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
	@Environment(SimulatorFeature.self) private var simulatorFeature
	let simulator: Simulator

	var body: some View {
		Button("Shutdown") {
			simulatorFeature.send(.updateSimulatorState(simulator, .shutdown))
		}
	}
}

private struct InstalledApplicationsForEachView: View {
    @Environment(InstalledApplicationsFeature.self) private var installedApplicationsFeature
	let applications: [Simulator.Application]

	var body: some View {
		ForEach(applications) { application in
			Menu(application.CFBundleDisplayName) {
				Button("Application Data") {
                    installedApplicationsFeature.send(.openApplicationDataFolder(application))
				}

				Button("Open User Defaults") {
                    installedApplicationsFeature.send(.openUserDefaults(application))
				}
			}
		}
	}
}
