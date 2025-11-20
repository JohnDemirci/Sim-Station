//
//  BatteryStatusStore.swift
//  Sim Station
//
//  Created by John Demirci on 9/11/25.
//

import Foundation
import SSM
import SwiftUI

struct BatteryStatusReducer: Reducer {
	struct State: Identifiable {
		let id: Simulator.ID
		var savedState: LoadableValue<BatteryState, Error> = .idle
		var settingBatteryState: LoadableValue<Date, Error> = .idle

		var level: Int = -1
		var chargeState: BatteryChargeState = .unknown

		var batteryState: BatteryState {
			.init(chargeState: chargeState, batteryLevel: level)
		}
	}

	enum Request {
		case retrieveCurrentState
		case setNewBatteryState
		case updateLevel(Int)
		case updateState(BatteryChargeState)
	}

    struct Environment: Sendable {
		let retrieveBatteryStateCommand: @Sendable (Simulator.ID) -> RetrieveBatteryStateCommand
		let setNewBatteryStateCommand: @Sendable (Simulator.ID, BatteryState) -> SetNewBatteryStateCommand
	}

	func reduce(store: Store<BatteryStatusReducer>, request: Request) async {
		switch request {
		case .retrieveCurrentState:
			await load(store: store, keyPath: \.savedState) {
				try await $0.retrieveBatteryStateCommand(store.state.id).run()
			}

			guard case .loaded(let loadingSuccess) = store.savedState else {
				return
			}

			modifyValue(store: store, \.level) {
				$0 = loadingSuccess.value.batteryLevel
			}
			modifyValue(store: store, \.chargeState) {
				$0 = loadingSuccess.value.chargeState
			}

		case .setNewBatteryState:
			guard store.batteryState.batteryLevel >= 0 && store.batteryState.batteryLevel <= 100 else { return }
			guard store.batteryState.chargeState != .unknown else { return }

			await load(
				store: store,
				keyPath: \.settingBatteryState,
				work: {
					try await $0.setNewBatteryStateCommand(
						store.state.id,
						store.batteryState
					)
					.run()
				},
				map: { _ in .now }
			)

			guard case .loaded = store.settingBatteryState else { return }

		case .updateLevel(let newLevel):
			modifyValue(store: store, \.level) {
				$0 = newLevel
			}

		case .updateState(let newState):
			modifyValue(store: store, \.chargeState) {
				$0 = newState
			}
		}
	}
}

extension BatteryStatusReducer.State {
	struct ViewState {
		var level: Int
		var chargeState: BatteryChargeState
		var batteryState: BatteryState {
			BatteryState(chargeState: chargeState, batteryLevel: level)
		}
	}

	var batteryColor: Color {
		switch level {
		case 0...20: return .red
		case 21...50: return .orange
		case 51...80: return .yellow
		default: return .green
		}
	}
}

extension StoreContrainer where Environment == AppEnvironment {
	func batteryStatusStore(_ id: Simulator.ID) -> BatteryStatusStore {
		store(state: BatteryStatusReducer.State(id: id)) {
			BatteryStatusReducer.Environment(
				retrieveBatteryStateCommand: $0.retrieveBatteryStateCommand,
				setNewBatteryStateCommand: $0.setNewBatteryStateCommand
			)
		}
	}
}

typealias BatteryStatusStore = Store<BatteryStatusReducer>
extension KeyPath: @retroactive @unchecked Sendable where Root: Sendable, Value: Sendable {
    
}
