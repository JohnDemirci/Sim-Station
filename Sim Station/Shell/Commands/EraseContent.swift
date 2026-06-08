//
//  EraseContent.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/24/25.
//

import Foundation

struct EraseSimulatorContentShellCommand: ShellCommand {
    let processesToRunPrior: [any ShellCommand]
    let postActionCommands: [any ShellCommand]

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(_ id: Simulator.ID) {
        self.processesToRunPrior = [
            ShutdownSimulatorShellCommand(id)
        ]

        self.postActionCommands = [
            OpenSimulatorShellCommand(id)
        ]

        self.path = .xcrun
        self.tokens = [.simctl, .erase, .custom(id)]
    }

    func run() async throws {
        for prior in processesToRunPrior {
            _ = try await prior.run()
        }
        
        try await rawData(for: build())

        for postActionCommand in postActionCommands {
            _ = try await postActionCommand.run()
        }
    }
}
