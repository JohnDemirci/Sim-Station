//
//  ActiveProcessesReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM

struct ActiveProcessesReducer: Reducer {
	struct State: Identifiable {
		let id: Simulator.ID
		var processes: LoadableValue<[Simulator.Process], Error> = .idle
	}

	enum Request {
		case retrieveProcesses
	}

	struct Environment {
		let retrieveActiveProcessesCommand: @Sendable (Simulator.ID) -> RetrieveActiveProcessesShellCommand
	}

    func reduce(store: Store<Self>, request: Request) async {
		switch request {
		case .retrieveProcesses:
			await load(store: store,keyPath: \.processes) {
				try await $0.retrieveActiveProcessesCommand(store.state.id)
					.run()
			}
		}
	}
}

extension StoreContrainer where Environment == AppEnvironment {
	func activeProcessesStore(_ id: Simulator.ID) -> Store<ActiveProcessesReducer> {
		store(state: ActiveProcessesReducer.State(id: id)) {
			ActiveProcessesReducer.Environment(
				retrieveActiveProcessesCommand: $0.retrieveActiveProcessesCommand
			)
		}
	}
}

typealias ActiveProcessesStore = Store<ActiveProcessesReducer>
