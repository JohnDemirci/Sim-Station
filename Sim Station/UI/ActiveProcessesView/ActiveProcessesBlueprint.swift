//
//  ActiveProcessesBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//


import Supervision
import LoadableValue

struct ActiveProcessesBlueprint: FeatureBlueprint {
    @ObservableValue
    struct State: Identifiable, Equatable {
        let id: Simulator.ID
        var processes: LoadableValue<[Simulator.Process], Error> = .idle

        init(_ id: Simulator.ID) {
            self.id = id
        }
    }

    enum Action {
        case retrieveProcesses
        case retrieveProcessesResult(Result<[Simulator.Process], Error>)
    }

    struct Dependency {
        let retrieveActiveProcessesCommand: @Sendable (Simulator.ID) -> RetrieveActiveProcessesShellCommand
    }

    func process(action: Action, context: borrowing Context<State>, featureID: Supervision.ReferenceIdentifier) -> FeatureWork {
        switch action {
        case .retrieveProcesses:
            context.processes = .loading
            let id = context.state.id

            return .run { dependency in
                try await dependency.retrieveActiveProcessesCommand(id).run()
            } map: { result in
                .retrieveProcessesResult(result)
            }

        case .retrieveProcessesResult(let result):
            switch result {
            case .success(let processes):
                context.processes = .loaded(LoadingSuccess(value: processes, timestamp: .now))
            case .failure(let error):
                context.processes = .failed(LoadingFailure(failure: error, timestamp: .now))
            }

            return .done
        }
    }
}

typealias ActiveProcessesFeature = Feature<ActiveProcessesBlueprint>

extension FeatureContainer where Dependency == AppEnvironment {
    func activeProcessesFeature(for simulatorID: Simulator.ID) -> ActiveProcessesFeature {
        feature(state: ActiveProcessesBlueprint.State(simulatorID)) { dependency in
            ActiveProcessesBlueprint.Dependency(retrieveActiveProcessesCommand: dependency.retrieveActiveProcessesCommand)
        }
    }
}
