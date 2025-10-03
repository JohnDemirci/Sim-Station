//
//  OpenSimulator.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation

struct OpenSimulatorShellCommand: ShellCommand {
    typealias Result = Void

    let processesToRunPrior: [any ShellCommand]
    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(
        _ id: Simulator.ID
    ) {
        self.path = .open
        self.processesToRunPrior = [BootCommand(id: id)]
        self.tokens = [
            .custom("-a"),
            .simulator,
            .doubleDashArgs,
            .custom("-CurrentDeviceUDID"),
            .custom(id)
        ]
    }

    func run() async throws {
        for processToRunPrior in processesToRunPrior {
            let _ = try await processToRunPrior.run()
        }
        
        try await rawData(for: build())
    }
}

extension OpenSimulatorShellCommand {
    private struct BootCommand: ShellCommand {
        typealias Result = Void

        let path: ShellCommandPath
        let tokens: [ShellCommandToken]

        init(
            id: Simulator.ID
        ) {
            self.path = .xcrun
            self.tokens = [.simctl, .boot, .custom(id)]
        }

        func run() async throws {
            _ = try await rawData(for: build())
        }
    }
}
