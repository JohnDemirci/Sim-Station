//
//  RetrieveBatteryStateCommand.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/14/25.
//

import Foundation

struct RetrieveBatteryStateCommand: ShellCommand {
    enum Failure: Error {
        case decodingError
        case unableToDecodeStateOrLevel
        case unexpectedOutput
        case unexpedtedNumberOfLinesDecoded
    }

    typealias Result = BatteryState

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(_ id: Simulator.ID) {
        path = .xcrun
        tokens = [
            .simctl,
            .statusBar,
            .custom(id),
            .list
        ]
    }

    func run() async throws -> BatteryState {
        let data = try await rawData(for: build())

        guard let output = String(data: data, encoding: .utf8) else {
            throw Failure.decodingError
        }

        let lines = output.split(separator: "\n")
            .map(\.self)

        switch lines.count {
        case 2: // battery state was not overwritten before
            return BatteryState(chargeState: .charged, batteryLevel: 100)
        case 3: // battery state was overwritten before
            return try getOverwrittenBatteryState(from: lines)
        default: // unexpected default should execution point should never reach here.
            throw Failure.unexpedtedNumberOfLinesDecoded
        }
    }
}

extension RetrieveBatteryStateCommand {
    private func getOverwrittenBatteryState(
        from lines: [String.SubSequence]
    ) throws -> BatteryState {
        let reversed = lines.reversed()
        let batteryLine = reversed.first {
            $0.localizedStandardContains("Battery State:")
        }

        guard let batteryLine else { throw Failure.unexpectedOutput }

        let components = batteryLine.split(separator: ",")
            .map { String($0) }

        var chargeStatus: BatteryChargeState?
        var level: Int?

        components.forEach { (component: String) in
            if component.contains("State:") {
                let state = component.split(separator: " ")
                    .map { "\($0)" }
                    .last!

                switch Int(state) {
                case 0:
                    chargeStatus = .discharging
                case 1:
                    chargeStatus = .charging
                case 2:
                    chargeStatus = .charged
                default:
                    chargeStatus = .charged
                }
            } else if component.contains("Level:") {
                let levelString = component.split(separator: " ")
                    .map { "\($0)" }
                    .last!

                level = Int(levelString)!
            }
        }

        guard let chargeStatus, let level else {
            throw Failure.unableToDecodeStateOrLevel
        }

        return BatteryState(chargeState: chargeStatus, batteryLevel: level)
    }
}
