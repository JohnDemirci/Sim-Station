//
//  CreateSimulatorReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Foundation
import SSM
import SwiftUI

struct CreateSimulatorReducer: Reducer {
	struct State {
		var creatingSimulator: LoadableValue<Date, Error> = .idle
		var runtimes: LoadableValue<[SimulatorRuntime], Error> = .idle
		var tab: Destination = .runtimes
		var selectedDeviceType: DeviceType?
		var selectedRuntime: SimulatorRuntime?
		var selectedName: String = ""
	}

	enum Request {
		case createSimulator
		case navigate(Destination)
		case reset
		case retrieveRuntimes
		case selectDeviceType(DeviceType)
		case selectName(String)
		case selectRuntime(SimulatorRuntime)
	}

    struct Environment: Sendable {
		let createSimulatorCommand: @Sendable (CreateSimulatorCommand.Parameters) -> CreateSimulatorCommand
		let retrieveRuntimesCommand: RetrieveSimulatorRuntimesCommand
	}

	func reduce(store: Store<CreateSimulatorReducer>, request: Request) async {
		switch request {
		case .createSimulator:
			await handleCreateSimulator(store)

		case .navigate(let destination):
			guard destination != store.state.tab else { return }
			modifyValue(store: store, \.tab) { $0 = destination }

		case .reset:
			modifyValue(store: store, \.selectedDeviceType) {
				$0 = nil
			}
			modifyValue(store: store, \.selectedName) {
				$0 = ""
			}
			modifyValue(store: store, \.selectedRuntime) {
				$0 = nil
			}
			modifyValue(store: store, \.tab) {
				$0 = .runtimes
			}

		case .retrieveRuntimes:
			await load(store: store, keyPath: \.runtimes) {
				try await $0.retrieveRuntimesCommand.run()
			}

		case .selectDeviceType(let deviceType):
			guard store.selectedDeviceType != deviceType else { return }
			modifyValue(store: store, \.selectedDeviceType) {
				$0 = deviceType
			}

		case .selectName(let newName):
			guard store.selectedName != newName else { return }
			modifyValue(store: store, \.selectedName) {
				$0 = newName
			}

		case .selectRuntime(let runtime):
			guard store.selectedRuntime != runtime else { return }
			modifyValue(store: store, \.selectedRuntime) {
				$0 = runtime
			}
		}
	}
}

extension CreateSimulatorReducer {
	func handleCreateSimulator(_ store: CreateSimulatorStore) async {
		guard let selectedRuntime = store.selectedRuntime else { return }
		guard let selectedDeviceType = store.selectedDeviceType else { return }
		guard store.selectedName.count > 3 else { return }

		let parameters = CreateSimulatorCommand.Parameters(
			deviceType: selectedDeviceType.identifier,
			name: store.selectedName,
			runtime: selectedRuntime.identifier
		)

		await load(
			store: store,
			keyPath: \.creatingSimulator,
			work: {
				try await $0.createSimulatorCommand(parameters).run()
			},
			map: { Date() }
		)

		switch store.creatingSimulator {
		case .cancelled(let cancellationDate):
			modifyValue(store: store, \.tab) {
				$0 = .failure("Action cancelled on \(cancellationDate)")
			}

		case .failed(let loadingFailure):
			modifyValue(store: store, \.tab) {
				$0 = .failure(loadingFailure.failure.localizedDescription)
			}

		case .loaded(let loadingSuccess):
			let message = CreateSimulatorMessage(
				id: loadingSuccess.value,
				name: "simulator-created",
				originatingFrom: store
			)

			broadcast(message)

			modifyValue(store: store, \.tab) { $0 = .success }
		case .loading, .idle:
			modifyValue(store: store, \.tab) {
				$0 = .failure("the state is at \(store.creatingSimulator) this should enver happen")
			}
		}
	}
}

extension StoreContrainer where Environment == AppEnvironment {
	func createSimulatorStore() -> Store<CreateSimulatorReducer> {
		store(state: CreateSimulatorReducer.State()) {
			CreateSimulatorReducer.Environment(
				createSimulatorCommand: $0.createSimulatorCommand,
				retrieveRuntimesCommand: $0.retrieveSimulatorRuntimesCommand
			)
		}
	}
}

typealias CreateSimulatorStore = Store<CreateSimulatorReducer>

extension CreateSimulatorReducer {
	enum Destination: HashIdentifiable {
		case deviceType
		case runtimes
		case nameSelection
		case overview
		case success
		case failure(String)

		var stringValue: String {
			switch self {
			case .deviceType:
				return "Device Model"
			case .runtimes:
				return "Runtime"
			case .nameSelection:
				return "Name"
			case .overview:
				return "Overview"
			case .failure:
				return "Failure"
			case .success:
				return "Success"
			}
		}
	}
}

extension CreateSimulatorReducer.State {
	var progressBarColor: Color {
		switch tab {
		case .runtimes, .deviceType, .nameSelection, .overview:
			return .accentColor
		case .success:
			return .green
		case .failure:
			return .red
		}
	}

	var progress: CGFloat {
		switch tab {
		case .runtimes:
			0.25
		case .deviceType:
			0.50
		case .nameSelection:
			0.75
		case .overview:
			0.90
		case .failure:
			0.90
		case .success:
			1
		}
	}

	var iconSystemImage: String {
		if selectedRuntime?.name.localizedStandardContains("watch") == true {
			return "applewatch"
		}

		if selectedRuntime?.name.localizedStandardContains("vision") ?? true {
			return "vision.pro"
		}

		if selectedDeviceType?.name.localizedStandardContains("ipad") == true {
			return "ipad"
		}

		if selectedRuntime?.name.localizedStandardContains("tv") == true {
			return "appletv"
		}

		return "iphone"
	}
}

struct CreateSimulatorMessage: BroadcastMessage {
	let id: Date
	var name: String
	var originatingFrom: any SSM.StoreProtocol
}
