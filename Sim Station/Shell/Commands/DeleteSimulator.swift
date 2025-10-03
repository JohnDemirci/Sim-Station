//
//  DeleteSimulator.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/28/25.
//

import Foundation

struct DeleteSimulatorShellCommand: ShellCommand {
    enum Failure: Error, HashIdentifiable {
        case terminationStatusError
    }

    typealias Result = Void
    var path: ShellCommandPath
    var tokens: [ShellCommandToken]

    init(_ id: Simulator.ID) {
        self.path = .xcrun
        self.tokens = [
            .simctl,
            .delete,
            .custom(id)
        ]
    }

    func run() async throws -> Void {
        let process = build()
        try await rawData(for: process)

        if process.terminationStatus != 0 {
            throw Failure.terminationStatusError
        }
    }
}
