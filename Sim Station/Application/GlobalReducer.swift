//
//  GlobalReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM

struct GlobalReducer: Reducer {
    func setupSubscriptions<SP>(store: SP) {}
    
	struct State {
		var openActiveProcesses: WindowID<Simulator.ID> = .init(.activeProcesses)
		var openBatteryStatus: WindowID<Simulator.ID> = .init(.batteryStatus)
		var openCreateSimulator: WindowID<EquatableVoid> = .init(.createSimulator)
		var openSimulatorInformation: WindowID<Simulator> = .init(.simulatorInformation)
	}

	enum Request {
        case dismissCreateSimulator
		case openActiveProcesses(Simulator.ID?)
		case openBatteryStatus(Simulator.ID?)
		case openCreateSimulator
		case openSimulatorInformation(Simulator?)
	}

    func reduce(store: Store<Self>, request: Request) async {
		switch request {
        case .dismissCreateSimulator:
            modifyValue(store: store, \.openCreateSimulator) {
                $0.value = nil
            }
            
		case .openActiveProcesses(let simulatorID):
			modifyValue(store: store, \.openActiveProcesses) {
				$0.value = simulatorID
			}

		case .openBatteryStatus(let simulatorID):
			modifyValue(store: store, \.openBatteryStatus) {
				$0.value = simulatorID
			}

		case .openCreateSimulator:
			modifyValue(store: store, \.openCreateSimulator) {
				$0.value = EquatableVoid()
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
