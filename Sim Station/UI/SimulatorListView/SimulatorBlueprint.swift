//
//  SimulatorBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import OrderedCollections
import LoadableValue
import AppKit
import Supervision

struct SimulatorBlueprint: FeatureBlueprint {
    enum Failure: Error {
        case simulatorOSNotFound
        case simulatorNotFound
    }

    @ObservableValue
    struct State: Equatable {
        var deletingSimulator: LoadableValue<Simulator, Error> = .idle
        var simulators: LoadableValue<OrderedDictionary<OS.Name, [Simulator]>, Error> = .idle
        var updatingSimulatorState: LoadableValue<Simulator, Error> = .idle
    }

    enum Action {
        case deleteAllSimulators(OS.Name)
        case deleteAllSimulatorResult([Simulator])
        case deleteSimulator(Simulator)
        case deleteSimulatorResult(Result<Simulator, Error>)
        case retrieveSimulators
        case retrieveSimulatorsResult(Result<OrderedDictionary<OS.Name, [Simulator]>, Error>)
        case updateSimulatorState(Simulator, Simulator.State)
        case updateSimulatorStateResult(Result<Simulator, Error>)
    }

    struct Dependency: Sendable {
        let deleteSimulatorCommand: @Sendable (Simulator.ID) -> DeleteSimulatorShellCommand
        let openSimulatorCommand: @Sendable (Simulator.ID) -> OpenSimulatorShellCommand
        let retrieveSimulatorCommand: RetrieveSimulatorsCommand
        let shutdownSimulatorCommand: @Sendable (Simulator.ID) -> ShutdownSimulatorShellCommand
    }

    func process(
        action: Action,
        context: borrowing Context<State>,
        featureID: Supervision.ReferenceIdentifier
    ) -> FeatureWork {
        switch action {
        case .deleteAllSimulators(let os):
            guard let simulators = context.state.simulators.value?[os] else {
                return .done
            }

            return .run { dependency in
                var deletedSimulators: [Simulator] = []
                for simulator in simulators {
                    do {
                        try await dependency.deleteSimulatorCommand(simulator.id).run()
                        deletedSimulators.append(simulator)
                    } catch {
                        continue
                    }
                }
                return deletedSimulators
            } map: { result in
                .deleteAllSimulatorResult(try! result.get())
            }

        case .deleteAllSimulatorResult(let simulators):
            context.simulators.modify { dictionary in
                for simulator in simulators {
                    if let os = simulator.os {
                        dictionary[os]?.removeAll { sim in
                            sim.id == simulator.id
                        }

                        if dictionary[os]?.isEmpty == true {
                            dictionary[os] = nil
                        }
                    }
                }
            }

            return .done

        case .deleteSimulator(let simulator):
            context.deletingSimulator = .loading
            return .run { dependency in
                try await dependency.deleteSimulatorCommand(simulator.id).run()
            } map: { result in
                .deleteSimulatorResult(result.map { _ in simulator })
            }

        case .deleteSimulatorResult(let result):
            switch result {
            case .success(let simulator):
                guard let os = simulator.os else {
                    context.deletingSimulator = .failed(
                        LoadingFailure(failure: Failure.simulatorOSNotFound, timestamp: .now)
                    )
                    return .done
                }

                context.simulators.modify { dictionary in
                    guard let index = dictionary[os]?.firstIndex(of: simulator) else { return }
                    dictionary[os]?.remove(at: index)

                    if dictionary[os]?.isEmpty == true {
                        dictionary[os] = nil
                    }
                }

                context.deletingSimulator = .loaded(
                    LoadingSuccess(value: simulator, timestamp: .now)
                )
                return .done

            case .failure(let error):
                context.deletingSimulator = .failed(
                    LoadingFailure(failure: error, timestamp: .now)
                )
                return .done
            }

        case .retrieveSimulators:
            context.simulators = .loading

            return .run { dependency in
                try await dependency.retrieveSimulatorCommand.run()
            } map: { result in
                .retrieveSimulatorsResult(result)
            }

        case .retrieveSimulatorsResult(let result):
            switch result {
            case .success(let dictionary):
                context.simulators = .loaded(LoadingSuccess(value: dictionary, timestamp: .now))
                return .done

            case .failure(let error):
                context.simulators = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }

        case .updateSimulatorState(let simulator, let simulatorState):
            context.updatingSimulatorState = .loading

            return .run { dependency in
                simulatorState == .booted ? try await dependency.openSimulatorCommand(simulator.id).run() : try await dependency.shutdownSimulatorCommand(simulator.id).run()
            } map: { result in
                .updateSimulatorStateResult(result.map { _ in simulator })
            }

        case .updateSimulatorStateResult(let result):
            switch result {
            case .success(let simulator):
                guard let os = simulator.os else {
                    context.updatingSimulatorState = .failed(LoadingFailure(failure: Failure.simulatorOSNotFound, timestamp: .now))
                    return .done
                }

                let index = context.simulators.value?[os]?.firstIndex(of: simulator)

                guard let index else {
                    context.updatingSimulatorState = .failed(LoadingFailure(failure: Failure.simulatorNotFound, timestamp: .now))
                    return .done
                }

                context.simulators.modify { dictionary in
                    dictionary[os]?[index].state = simulator.state?.opposite()
                }

                guard let newSimulator = context.simulators.value?[os]?[index] else {
                    context.updatingSimulatorState = .failed(LoadingFailure(failure: Failure.simulatorNotFound, timestamp: .now))
                    return .done
                }

                context.updatingSimulatorState = .loaded(LoadingSuccess(value: newSimulator, timestamp: .now))
                return .done

            case .failure(let error):
                context.updatingSimulatorState = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }
        }
    }
}

typealias SimulatorFeature = Feature<SimulatorBlueprint>

extension FeatureContainer where Dependency == AppEnvironment {
    func simulatorFeature() -> SimulatorFeature {
        feature(
            state: SimulatorBlueprint.State()) { dependency in
                SimulatorBlueprint.Dependency(
                    deleteSimulatorCommand: dependency.deleteSimulatorCommand,
                    openSimulatorCommand: dependency.openSimulatorCommand,
                    retrieveSimulatorCommand: dependency.retrieveSimulatorCommand,
                    shutdownSimulatorCommand: dependency.shutdownSimulatorCommand
                )
            }
    }
}
