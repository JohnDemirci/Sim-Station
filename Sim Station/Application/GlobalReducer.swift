//
//  GlobalReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM

struct GlobalReducer: Reducer {
	struct State {
		var openActiveProcesses: WindowID<Simulator.ID> = .init(.activeProcesses)
		var openBatteryStatus: WindowID<Simulator.ID> = .init(.batteryStatus)
		var openCreateSimulator: WindowID<EquatableVoid> = .init(.createSimulator)
		var openSimulatorInformation: WindowID<Simulator> = .init(.simulatorInformation)
	}

	enum Request {
		case openActiveProcesses(Simulator.ID?)
		case openBatteryStatus(Simulator.ID?)
		case openCreateSimulator(EquatableVoid?)
		case openSimulatorInformation(Simulator?)
	}

	func reduce(store: Store<GlobalReducer>, request: Request) async {
		switch request {
		case .openActiveProcesses(let simulatorID):
			modifyValue(store: store, \.openActiveProcesses) {
				$0.value = simulatorID
			}

		case .openBatteryStatus(let simulatorID):
			modifyValue(store: store, \.openBatteryStatus) {
				$0.value = simulatorID
			}

		case .openCreateSimulator(let void):
			modifyValue(store: store, \.openCreateSimulator) {
				$0.value = void
			}

		case .openSimulatorInformation(let simulator):
			modifyValue(store: store,\.openSimulatorInformation) {
				$0.value = simulator
			}
		}
	}
}

extension StoreContrainer {
	func globalStore() -> Store<GlobalReducer> {
		store(state: GlobalReducer.State())
	}
}

typealias GlobalStore = Store<GlobalReducer>
