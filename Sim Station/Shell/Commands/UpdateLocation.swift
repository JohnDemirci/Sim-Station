//
//  UpdateLocation.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/8/25.
//

import Foundation

struct UpdateLocationCommand: ShellCommand {
    typealias Result = EquatableVoid

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(_ id: Simulator.ID, latitude: Double, longitude: Double) {
        self.path = .xcrun
        self.tokens = [
            .simctl,
            .location,
            .custom(id),
            .set,
            .custom("\(latitude),\(longitude)")
        ]
    }

    func run() async throws -> Result {
        try await rawData(for: build())
        return EquatableVoid()
    }
}
