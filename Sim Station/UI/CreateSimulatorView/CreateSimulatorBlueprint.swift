//
//  CreateSimulatorBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Foundation
import LoadableValue
import SwiftUI
import Supervision

struct CreateSimulatorBlueprint: FeatureBlueprint {
    enum Failure: Error, Hashable {
        case runtimeNotSelected
        case deviceTypeNotSelected
        case nameTooShort
    }

    @ObservableValue
    struct State: Equatable {
        var creatingSimulator: LoadableValue<Date, Error> = .idle
        var runtimes: LoadableValue<[SimulatorRuntime], Error> = .idle
        var tab: Destination = .runtimes
        var selectedDeviceType: DeviceType?
        var selectedRuntime: SimulatorRuntime?
        var selectedName: String = ""
    }

    enum Action {
        case createSimulator
        case createSimulatorResult(Result<Date, Error>)
        case navigate(Destination)
        case reset
        case retrieveRuntimes
        case retrieveRuntimesResult(Result<[SimulatorRuntime], Error>)
        case selectDeviceType(DeviceType?)
        case selectName(String)
        case selectRuntime(SimulatorRuntime?)
    }

    struct Dependency: Sendable {
        let createSimulatorCommand: @Sendable (CreateSimulatorCommand.Parameters) -> CreateSimulatorCommand
        let broadcaster: Broadcaster
        let retrieveRuntimesCommand: RetrieveSimulatorRuntimesCommand
    }

    func process(action: Action, context: borrowing Context<State>, featureID: Supervision.ReferenceIdentifier) -> FeatureWork {
        switch action {
        case .createSimulator:
            context.creatingSimulator = .loading
            guard let selectedRuntime = context.state.selectedRuntime else {
                context.creatingSimulator = .failed(LoadingFailure(failure: Failure.runtimeNotSelected, timestamp: .now))
                return .done
            }

            guard let selectedDeviceType = context.state.selectedDeviceType else {
                context.creatingSimulator = .failed(LoadingFailure(failure: Failure.deviceTypeNotSelected, timestamp: .now))
                return .done
            }

            guard context.state.selectedName.count > 3 else {
                context.creatingSimulator = .failed(LoadingFailure(failure: Failure.nameTooShort, timestamp: .now))
                return .done
            }

            let parameters = CreateSimulatorCommand.Parameters(
                deviceType: selectedDeviceType.identifier,
                name: context.state.selectedName,
                runtime: selectedRuntime.identifier
            )

            return .run { dependency in
                try await dependency.createSimulatorCommand(parameters).run()
            } map: { result in
                .createSimulatorResult(result.map { _ in Date() })
            }

        case .createSimulatorResult(let result):
            switch result {
            case .success(let date):
                context.creatingSimulator = .loaded(LoadingSuccess(value: date, timestamp: date))

                let message = SimulatorEvent(
                    kind: .created,
                    title: "Created",
                    sender: featureID
                )

                return .fireAndForget { dependency in
                    await dependency.broadcaster.broadcast(message: message)
                }

            case .failure(let error):
                context.creatingSimulator = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }

        case .navigate(let destination):
            guard destination != context.state.tab else { return .done }
            context.tab = destination
            return .done

        case .reset:
            context.selectedDeviceType = nil
            context.selectedName = ""
            context.selectedRuntime = nil
            context.tab = .runtimes

            return .done

        case .retrieveRuntimes:
            context.runtimes = .loading
            return .run { dependency in
                try await dependency.retrieveRuntimesCommand.run()
            } map: { result in
                .retrieveRuntimesResult(result)
            }

        case .retrieveRuntimesResult(let result):
            switch result {
            case .success(let runtimes):
                context.runtimes = .loaded(LoadingSuccess(value: runtimes, timestamp: .now))
                return .done
            case .failure(let error):
                context.runtimes = .failed(LoadingFailure(failure: error, timestamp: .now))
                return .done
            }

        case .selectDeviceType(let selectedDeviceType):
            context.selectedDeviceType = selectedDeviceType
            return .done

        case .selectName(let selectedName):
            context.selectedName = selectedName
            return .done

        case .selectRuntime(let selectedRuntime):
            context.selectedRuntime = selectedRuntime
            return .done
        }
    }
}

extension CreateSimulatorBlueprint {
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

extension CreateSimulatorBlueprint.State {
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


struct SimulatorEvent: Supervision.BroadcastMessage {
    enum MessageKind: BroadcastMessageKind {
        case created
    }

    var kind: MessageKind
    var date: Date
    var title: String
    var sender: Supervision.ReferenceIdentifier?

    init(
        kind: MessageKind,
        date: Date = .now,
        title: String,
        sender: Supervision.ReferenceIdentifier? = nil
    ) {
        self.kind = kind
        self.date = date
        self.title = title
        self.sender = sender
    }
}

typealias CreateSimulatorFeature = Feature<CreateSimulatorBlueprint>
typealias CreateSimulatorFeatureState = FeatureState<CreateSimulatorBlueprint>

extension FeatureContainer where Dependency == AppEnvironment {
    func createSimulatorFeature() -> CreateSimulatorFeature {
        feature(state: CreateSimulatorBlueprint.State()) { dependency in
            CreateSimulatorBlueprint.Dependency(
                createSimulatorCommand: dependency.createSimulatorCommand,
                broadcaster: dependency.broadcaster,
                retrieveRuntimesCommand: dependency.retrieveSimulatorRuntimesCommand
            )
        }
    }
}
