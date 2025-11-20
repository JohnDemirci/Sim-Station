//
//  SimulatorReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Combine
import OrderedCollections
import SSM
import AppKit

extension NSNotification: @unchecked @retroactive Sendable {}
extension Notification: @unchecked @retroactive Sendable {}

struct SimulatorReducer: Reducer {
	struct State {
		var deletingSimulator: LoadableValue<Simulator, Error> = .idle
		var simulators: LoadableValue<OrderedDictionary<OS.Name, [Simulator]>, Error> = .idle
		var updatingSimulatorState: LoadableValue<Simulator, Error> = .idle
	}

	enum Request {
		case deleteSimulator(Simulator)
		case retrieveSimulators
		case updateSimulatorState(Simulator, Simulator.State)
	}

    struct Environment: Sendable {
		let broadcastStudio: BroadcastStudio
		let notificationCenter: NotificationCenter
		let deleteSimulatorCommand: @Sendable (Simulator.ID) -> DeleteSimulatorShellCommand
		let openSimulatorCommand: @Sendable (Simulator.ID) -> OpenSimulatorShellCommand
		let retrieveSimulatorCommand: RetrieveSimulatorsCommand
		let shutdownSimulatorCommand: @Sendable (Simulator.ID) -> ShutdownSimulatorShellCommand
	}

	func reduce(store: Store<SimulatorReducer>, request: Request) async {
		switch request {
		case .deleteSimulator(let simulator):
			await load(
				store: store,
				keyPath: \.deletingSimulator,
				work: { try await $0.deleteSimulatorCommand(simulator.id).run() },
				map: { simulator }
			)

			switch store.state.deletingSimulator {
			case .cancelled(let cancellationDate):
				assertionFailure("cancelled at \(cancellationDate)")
			case .failed(let loadingFailure):
				assertionFailure(loadingFailure.failure.localizedDescription)
			case .loaded:
				guard let os = simulator.os else { return }

				modifyLoadedValue(store: store, \.simulators) { dictionary in
					guard let index = dictionary[os]?.firstIndex(of: simulator) else { return }
					dictionary[os]?.remove(at: index)

					if dictionary[os]?.isEmpty == true {
						dictionary[os] = nil
					}
				}
			case .loading:
				assertionFailure("TODO")
			case .idle:
				assertionFailure("TODO")
			}

		case .retrieveSimulators:
			await load(store: store, keyPath: \.simulators) {
				try await $0.retrieveSimulatorCommand.run()
			}

		case .updateSimulatorState(let simulator, let state):
			switch state {
			case .booted:
				await load(
					store: store,
					keyPath: \.updatingSimulatorState,
					work: { try await $0.openSimulatorCommand(simulator.id).run() },
					map: { simulator }
				)
			case .shutdown:
				await load(
					store: store,
					keyPath: \.updatingSimulatorState,
					work: { try await $0.shutdownSimulatorCommand(simulator.id).run() },
					map: { simulator }
				)
			}

			guard case .loaded = store.updatingSimulatorState else { return }
			guard let os = simulator.os else { return }

			modifyLoadedValue(store: store, \.simulators) { dictionary in
				let index = dictionary[os]?.firstIndex(of: simulator)
				guard let index else { return }
				dictionary[os]?[index].state = state
			}
		}
	}

	func setupSubscriptions(store: Store<SimulatorReducer>) {
		subscribe(store: store,keypath: \.notificationCenter) {
			$0.publisher(for: NSApplication.didBecomeActiveNotification)
				.eraseToAnyPublisher()
			} map: { _ in
				return .retrieveSimulators
			}


		subscribe(store: store, keypath: \.broadcastStudio, \.publisher) {
			switch $0 {
			case _ as CreateSimulatorMessage:
				return .retrieveSimulators
			default:
				return nil
			}
		}
	}
}

extension StoreContrainer where Environment == AppEnvironment {
	func simulatorStore() -> Store<SimulatorReducer> {
		store(state: SimulatorReducer.State()) {
			SimulatorReducer.Environment(
				broadcastStudio: $0.broadcast,
				notificationCenter: .default,
				deleteSimulatorCommand: $0.deleteSimulatorCommand,
				openSimulatorCommand: $0.openSimulatorCommand,
				retrieveSimulatorCommand: $0.retrieveSimulatorCommand,
				shutdownSimulatorCommand: $0.shutdownSimulatorCommand
			)
		}
	}
}

typealias SimulatorStore = Store<SimulatorReducer>
