//
//  OpenPath.swift
//  Jodem Sim
//
//  Created by John Demirci on 9/7/25.
//

import Foundation

struct OpenPathCommand: ShellCommand {
    typealias Result = EquatableVoid

    let path: ShellCommandPath = .open
    var tokens: [ShellCommandToken]

    init(path: String) {
        self.tokens = [.custom(path)]
    }

    func run() async throws -> EquatableVoid {
        try await rawData(for: build())
        return EquatableVoid()
    }
}
