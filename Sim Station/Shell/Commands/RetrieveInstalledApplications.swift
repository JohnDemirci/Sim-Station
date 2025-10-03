//
//  InstalledApplications.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/20/25.
//

import Foundation

struct RetrieveInstalledApplicationsCommand: ShellCommand {
    enum Failure: Error, HashIdentifiable {
        case decodingFailed
        case parsingFailed
    }

    typealias Result = [Simulator.Application]
    var tokens: [ShellCommandToken]
    var path: ShellCommandPath

    init(_ id: Simulator.ID) {
        self.path = .xcrun
        self.tokens = [
            .simctl,
            .listApps,
            .custom(id),
            .doubleDashJson
        ]
    }

    func run() async throws -> [Simulator.Application] {
        let data = try await rawData(for: build())
        let decoder = PropertyListDecoder()
        let appsDictionary = try decoder.decode([String: Simulator.Application].self, from: data)

        let apps = appsDictionary.compactMap { key, value -> Simulator.Application? in
            guard value.ApplicationType != "System" else { return nil }
            return value
        }

        return apps
    }
}
