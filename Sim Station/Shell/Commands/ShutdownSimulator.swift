//
//  ShutdownSimulator.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation

struct ShutdownSimulatorShellCommand: ShellCommand {
    typealias Result = Void

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(_ id: Simulator.ID) {
        self.path = .xcrun
        self.tokens = [.simctl, .shutdown, .custom(id)]
    }

    func run() async throws {
        try await rawData(for: build())
    }
}
