//
//  BatteryStatusBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/11/25.
//

import Foundation
import LoadableValue
import SwiftUI
import Supervision

struct BatteryStatusBlueprint: FeatureBlueprint {
    enum Failure: Error, Hashable {
        case batteryLevelOutOfRange
        case unknownChargeState
    }

    @ObservableValue
    struct State: Equatable, Identifiable {
        let id: Simulator.ID

        var savedState: LoadableValue<BatteryState, Error> = .idle
        var settingBatteryState: LoadableValue<BatteryState, Error> = .idle
        var level: Int = -1
        var chargeState: BatteryChargeState = .unknown

        var batteryState: BatteryState {
            .init(chargeState: chargeState, batteryLevel: level)
        }

        init(_ id: Simulator.ID) {
            self.id = id
        }
    }

    enum Action {
        case retrieveCurrentState
        case retrieveCurrentStateResult(Result<BatteryState, Error>)
        case setNewBatteryState
        case setNewBatteryStateResult(Result<BatteryState, Error>)
        case updateBatteryChargeState(BatteryChargeState)
        case updateLevel(Int)
    }

    struct Dependency: Sendable {
        let retrieveBatteryStateCommand: @Sendable (Simulator.ID) -> RetrieveBatteryStateCommand
        let setNewBatteryStateCommand: @Sendable (Simulator.ID, BatteryState) -> SetNewBatteryStateCommand
    }

    func process(action: Action, context: borrowing Context<State>, featureID: Supervision.ReferenceIdentifier) -> FeatureWork {
        switch action {
        case .retrieveCurrentState:
            context.savedState = .loading
            let id = context.state.id
            return .run { dependency in
                try await dependency.retrieveBatteryStateCommand(id).run()
            } map: { result in
                .retrieveCurrentStateResult(result)
            }

        case .retrieveCurrentStateResult(let result):
            switch result {
            case .success(let batteryState):
                context.savedState = .loaded(LoadingSuccess(value: batteryState, timestamp: .now))
                return .done

            case .failure(let error):
                context.savedState = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }

        case .setNewBatteryState:
            context.settingBatteryState = .loading
            guard context.state.batteryState.batteryLevel >= 0 && context.state.batteryState.batteryLevel <= 100 else {
                context.settingBatteryState = .failed(LoadingFailure(failure: Failure.batteryLevelOutOfRange, timestamp: .now))
                return .done
            }

            guard context.state.batteryState.chargeState != .unknown else {
                context.settingBatteryState = .failed(LoadingFailure(failure: Failure.unknownChargeState, timestamp: .now))
                return .done
            }

            let id = context.state.id
            let state = context.state.batteryState

            return .run { dependency in
                try await dependency.setNewBatteryStateCommand(id, state).run()
            } map: { result in
                .setNewBatteryStateResult(result.map { _ in state })
            }

        case .setNewBatteryStateResult(let result):
            switch result {
            case .success(let newState):
                context.savedState.modify { $0 = newState }
                context.settingBatteryState = .loaded(LoadingSuccess(value: newState, timestamp: .now))
                return .done

            case .failure(let error):
                context.settingBatteryState = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }

        case .updateBatteryChargeState(let batteryChargeState):
            context.chargeState = batteryChargeState
            return .done

        case .updateLevel(let level):
            context.level = level
            return .done
        }
    }
}

extension BatteryStatusBlueprint.State {
    var batteryColor: Color {
        switch level {
        case 0...20: return .red
        case 21...50: return .orange
        case 51...80: return .yellow
        default: return .green
        }
    }
}

typealias BatteryStatusFeature = Feature<BatteryStatusBlueprint>
typealias BatteryStatusFeatureState = FeatureState<BatteryStatusBlueprint>

extension FeatureContainer where Dependency == AppEnvironment {
    func batteryStatusFeature(_ id: Simulator.ID) -> BatteryStatusFeature {
        feature(state: BatteryStatusBlueprint.State(id)) { dependency in
            BatteryStatusBlueprint.Dependency(
                retrieveBatteryStateCommand: dependency.retrieveBatteryStateCommand,
                setNewBatteryStateCommand: dependency.setNewBatteryStateCommand
            )
        }
    }
}
