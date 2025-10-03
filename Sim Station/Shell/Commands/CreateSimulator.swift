//
//  CreateSimulator.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/29/25.
//

import Foundation

struct CreateSimulatorCommand: ShellCommand {
    enum Failure: Error, HashIdentifiable {
        case unknown
    }

    typealias Result = Void

    var path: ShellCommandPath
    var tokens: [ShellCommandToken]

    init(_ parameters: Parameters) {
        path = .xcrun
        tokens = [
            .simctl,
            .create,
            .custom(parameters.name),
            .custom(parameters.deviceType),
            .custom(parameters.runtime)
        ]
    }

    func run() async throws -> Void {
        let process = build()
        let result = try await rawData(for: process)

        let stringValue = String(data: result, encoding: .utf8) ?? ""
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard isValidUUID(stringValue) else {
            throw Failure.unknown
        }
    }

    private func isValidUUID(_ input: String) -> Bool {
        let uuidPattern = "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$"

        guard let regex = try? NSRegularExpression(pattern: uuidPattern) else {
            return false
        }

        let range = NSRange(location: 0, length: input.utf16.count)

        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
}

extension CreateSimulatorCommand {
    struct Parameters {
        let deviceType: String
        let name: String
        let runtime: String
    }
}
