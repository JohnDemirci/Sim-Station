//
//  WindowSceneBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Supervision

struct WindowSceneBlueprint: FeatureBlueprint {
    @ObservableValue
    struct State {
        var openActiveProcesses: WindowID<Simulator.ID> = .init(.activeProcesses)
        var openBatteryStatus: WindowID<Simulator.ID> = .init(.batteryStatus)
        var openCreateSimulator: WindowID<EquatableVoid> = .init(.createSimulator)
        var openSimulatorInformation: WindowID<Simulator> = .init(.simulatorInformation)
    }

    enum Action {
        case dismissCreateSimulator
        case openActiveProcesses(Simulator.ID?)
        case openBatteryStatus(Simulator.ID?)
        case openCreateSimulator
        case openSimulatorInformation(Simulator?)
    }

    typealias Dependency = Void

    func process(action: Action, context: borrowing Context<State>, featureID: Supervision.ReferenceIdentifier) -> FeatureWork {
        switch action {
        case .dismissCreateSimulator:
            context.openCreateSimulator.value = nil
            return .done
        case .openActiveProcesses(let simulatorID):
            context.openActiveProcesses.value = simulatorID
            return .done
        case .openBatteryStatus(let simulatorID):
            context.openBatteryStatus.value = simulatorID
            return .done
        case .openCreateSimulator:
            context.openCreateSimulator.value = EquatableVoid()
            return .done
        case .openSimulatorInformation(let simulator):
            context.openSimulatorInformation.value = simulator
            return .done
        }
    }
}

typealias WindowSceneFeature = Feature<WindowSceneBlueprint>

extension FeatureContainer {
    func windowSceneFeature() -> WindowSceneFeature {
        feature(state: WindowSceneBlueprint.State())
    }
}
