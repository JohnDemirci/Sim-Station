//
//  RetrieveSimulators.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation
import OrderedCollections

struct RetrieveSimulatorsCommand: ShellCommand {
    enum Failure: Error {
        case devicesNotFound
        case decodingFailed
    }

    typealias Result = OrderedDictionary<OS.Name, [Simulator]>

    let path: ShellCommandPath
    let tokens: [ShellCommandToken]

    init(
        path: ShellCommandPath = .xcrun,
        tokens: [ShellCommandToken] =  [.simctl, .list, .devices, .doubleDashJson]
    ) {
        self.path = .xcrun
        self.tokens = tokens
    }

    func run() async throws -> Result {
        let process = build()
        let dataRepresentation = try await rawData(for: process)
        guard let json = try JSONSerialization.jsonObject(
            with: dataRepresentation,
            options: []
        ) as? [String: Any] else {
            throw Failure.decodingFailed
        }

        guard let devicesDict = json["devices"] as? [String: [Any]] else {
            throw Failure.devicesNotFound
        }

        var dict = devicesDict.reduce(
            into: OrderedDictionary<OS.Name, [Simulator]>()
        ) { partialResult, kyp in
            guard let osName = getOSName(key: kyp.key) else { return }
            let simulatorListData = parseDataIntoSimulator(data: kyp.value, key: osName)
            if !simulatorListData.isEmpty {
                partialResult[osName] = parseDataIntoSimulator(
                    data: kyp.value,
                    key: osName
                )
            }
        }

        dict.sort { $0.key < $1.key }
        return dict
    }
}

extension RetrieveSimulatorsCommand {
    private func getDeviceModel(key: String) -> String {
        let seperator = "."
        return "\(key.split(separator: seperator).last ?? "")"
    }

    private func getOSName(key: String) -> OS.Name? {
        let seperator = "."

        let xxx = key.split(separator: seperator).last!
        let device: String = "\(xxx.split(separator: "-").first!)"
        var version = xxx.split(separator: "-")
        version.removeFirst()
        let finalVersion: String = version.joined(separator: "-")

        let osName = OS.Name(os: device, version: finalVersion)
        return osName
    }

    private func parseDataIntoSimulator(
           data: [Any],
           key: OS.Name?
    ) -> [Simulator] {
        return data.compactMap { maybeDict -> Simulator? in
            guard let dict = maybeDict as? [String: Any] else { return nil }
            var simulator = Simulator()

            if let dataPath = dict["dataPath"] as? String {
                simulator.dataPath = dataPath
            }

            if let logPath = dict["logPath"] as? String {
                simulator.logPath = logPath
            }

            if let udid = dict["udid"] as? String {
                simulator.udid = udid
            }

            if let deviceTypeIdentifier = dict["deviceTypeIdentifier"] as? String {
                let model = getDeviceModel(key: deviceTypeIdentifier)
                simulator.deviceTypeIdentifier = model
            }

            if let state = dict["state"] as? String {
                simulator.state = .init(rawValue: state)
            }

            if let dataPathSize = dict["dataPathSize"] as? Int {
                simulator.dataPathSize = dataPathSize
            }

            if let isAvailable = dict["isAvailable"] as? Bool {
                simulator.isAvailable = isAvailable
            }

            if let name = dict["name"] as? String {
                simulator.name = name
            }

            simulator.os = key

            return simulator
        }
    }
}
