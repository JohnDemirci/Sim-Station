//
//  FetchActiveProcesses.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/26/25.
//

import Foundation

struct RetrieveActiveProcessesShellCommand: ShellCommand {
    enum Failure: Error, HashIdentifiable {
        case decodingFailed
    }

    typealias Result = [Simulator.Process]
    var tokens: [ShellCommandToken]
    var path: ShellCommandPath

    init(_ id: Simulator.ID) {
        self.path = .bash
        self.tokens = [
            .custom("-c"),
            .custom("xcrun simctl spawn \(id) launchctl list"),
        ]
    }

    func run() async throws -> [Simulator.Process] {
        let result = try await rawData(for: build())
        let stringRepresentation = String(data: result, encoding: .utf8)

        guard let stringRepresentation else {
            throw Failure.decodingFailed
        }

        let lines = stringRepresentation.components(separatedBy: "\n")

        var processes = [Simulator.Process]()

        for line in lines.dropFirst() { // Drop the header line
            let components = line.components(separatedBy: "\t")
            if components.count == 3 {
                let processInfo = Simulator.Process(
                    label: components[2],
                    pid: components[0],
                    status: components[1]
                )
                processes.append(processInfo)
            }
        }

        return processes
    }
}
