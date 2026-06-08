//
//  InstalledapplicationsBlueprint.swift
//  Sim Station
//
//  Created by John Demirci on 9/30/25.
//

import Foundation
import LoadableValue
import SwiftUI
import Supervision

struct InstalledapplicationsBlueprint: FeatureBlueprint {
    enum Failure: Error, Hashable {
        case dataContainerNotFound
        case urlCastFailure
    }

    @ObservableValue
    struct State: Identifiable, Equatable {
        let id: Simulator.ID
        var applications: LoadableValue<[Simulator.Application], Error> = .idle
        var openingApplicationDataFolder: LoadableValue<Simulator.Application.ID, Error> = .idle
        var openingUserDefaults: LoadableValue<Simulator.Application.ID, Error> = .idle

        init(_ simulatorID: Simulator.ID) {
            id = simulatorID
        }
    }

    enum Action {
        case openApplicationDataFolder(Simulator.Application)
        case openApplicationDataFolderResult(Result<Simulator.Application.ID, Error>)
        case openUserDefaults(Simulator.Application)
        case openUserDefaultsResult(Result<Simulator.Application.ID, Error>)
        case retrieveInstalledApplications
        case retrieveInstalledApplicationsResult(Result<[Simulator.Application], Error>)
    }

    struct Dependency: Sendable {
        let retrieveInstalledApplicationsCommand: @Sendable (Simulator.ID) -> RetrieveInstalledApplicationsCommand
        let workspace: NSWorkspace
    }

    func process(action: Action, context: borrowing Context<State>, featureID: Supervision.ReferenceIdentifier) -> FeatureWork {
        switch action {
        case .openApplicationDataFolder(let application):
            context.openingApplicationDataFolder = .loading
            guard let container = application.DataContainer else {
                context.openingApplicationDataFolder = .failed(LoadingFailure(failure: Failure.dataContainerNotFound, timestamp: .now))
                return .done
            }

            guard let url = URL(string: container) else {
                context.openingApplicationDataFolder = .failed(LoadingFailure(failure: Failure.urlCastFailure, timestamp: .now))
                return .done
            }

            return .run { dependency in
                dependency.workspace.open(url)
            } map: { result in
                .openApplicationDataFolderResult(result.map { _ in application.id })
            }

        case .openApplicationDataFolderResult(let result):
            switch result {
            case .success(let applicationID):
                context.openingApplicationDataFolder = .loaded(LoadingSuccess(value: applicationID, timestamp: .now))
            case .failure(let error):
                context.openingApplicationDataFolder = .failed(LoadingFailure(failure: error, timestamp: .now))
            }
            return .done

        case .openUserDefaults(let application):
            context.openingUserDefaults = .loading

            guard let container = application.DataContainer else {
                context.openingUserDefaults = .failed(LoadingFailure(failure: Failure.dataContainerNotFound, timestamp: .now))
                return .done
            }

            guard let containerURL = URL(string: container) else {
                context.openingUserDefaults = .failed(LoadingFailure(failure: Failure.urlCastFailure, timestamp: .now))
                return .done
            }

            let plistFileName = "\(application.CFBundleIdentifier).plist"

            let preferencesURL = containerURL
                .appendingPathComponent("Library")
                .appendingPathComponent("Preferences")
                .appendingPathComponent(plistFileName)

            return .run { dependency in
                dependency.workspace.open(preferencesURL)
            } map: { result in
                .openUserDefaultsResult(result.map { _ in application.id })
            }

        case .openUserDefaultsResult(let result):
            switch result {
            case .success(let applicationID):
                context.openingUserDefaults = .loaded(LoadingSuccess(value: applicationID, timestamp: .now))
            case .failure(let error):
                context.openingUserDefaults = .failed(LoadingFailure(failure: error, timestamp: .now))
            }
            return .done

        case .retrieveInstalledApplications:
            context.applications = .loading
            let id = context.state.id

            return .run { dependency in
                try await dependency.retrieveInstalledApplicationsCommand(id).run()
            } map: { result in
                .retrieveInstalledApplicationsResult(result)
            }

        case .retrieveInstalledApplicationsResult(let result):
            switch result {
            case .success(let applications):
                context.applications = .loaded(LoadingSuccess(value: applications, timestamp: .now))
            case .failure(let error):
                context.applications = .failed(LoadingFailure(failure: error, timestamp: .now))
            }
            return .done
        }
    }
}

typealias InstalledApplicationsFeature = Feature<InstalledapplicationsBlueprint>
typealias InstalledApplicationsFeatureState = FeatureState<InstalledapplicationsBlueprint>

extension FeatureContainer where Dependency == AppEnvironment {
    func installedApplications(_ simulatorID: Simulator.ID) -> InstalledApplicationsFeature {
        feature(state: InstalledapplicationsBlueprint.State(simulatorID)) { dependency in
            InstalledapplicationsBlueprint.Dependency(
                retrieveInstalledApplicationsCommand: dependency.retrieveInstalledApplicationsCommand,
                workspace: dependency.workspace
            )
        }
    }
}
