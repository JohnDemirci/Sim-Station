//
//  SetNewBatteryState.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/15/25.
//

import Foundation

struct SetNewBatteryStateCommand: ShellCommand {
    typealias Result = EquatableVoid

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(
        simulatorID: Simulator.ID,
        state: BatteryState
    ) {
        self.path = .xcrun
        self.tokens = [
            .simctl,
            .statusBar,
            .custom(simulatorID),
            .override,
            .custom("--batteryState"),
            .custom(state.chargeState.rawValue),
            .custom("--batteryLevel"),
            .custom(String(state.batteryLevel))
        ]
    }

    func run() async throws -> EquatableVoid {
        let _ = try await rawData(for: build())
        return EquatableVoid()
    }
}
