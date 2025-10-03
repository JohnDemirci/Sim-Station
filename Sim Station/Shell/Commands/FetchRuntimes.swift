//
//  FetchRuntimes.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/29/25.
//

import Foundation

// MARK: - Legacy
struct FetchRuntimesCommand: ShellCommand {
    enum Failure: Error {
        case decodingFailed
    }
    
    typealias Result = [String]
    var path: ShellCommandPath = .xcrun
    var tokens: [ShellCommandToken] = [.simctl, .list, .runtimes]
    func run() async throws -> [String] {
        let rawData = try await rawData(for: build())

        guard
            let stringValue = String(data: rawData, encoding: .utf8),
            !stringValue.isEmpty
        else {
            throw Failure.decodingFailed
        }

        return stringValue
            .split(separator: "\n")
            .dropFirst()
            .map(\.self)
            .compactMap { str -> String? in
                let temp = str.split(separator: "com.apple")
                    .map(\.self)
                    .last?
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")

                guard let temp else { return nil }
                return "com.apple".appending(temp)
            }
    }
}

struct RetrieveSimulatorRuntimesCommand: ShellCommand {
    typealias Result = [SimulatorRuntime]

    var path: ShellCommandPath
    var tokens: [ShellCommandToken]

    init() {
        path = .xcrun
        tokens = [
            .simctl,
            .list,
            .custom("-j"),
            .runtimes
        ]
    }

    func run() async throws -> [SimulatorRuntime] {
        let rawData = try await rawData(for: build())
        let decoder = JSONDecoder()
        let response = try decoder.decode(SimulatorRuntimesResponse.self, from: rawData)
        return response.runtimes
    }
}
