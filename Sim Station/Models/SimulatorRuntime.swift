//
//  SimulatorRuntime.swift
//  Jodem Sim
//
//  Created by John Demirci on 7/17/25.
//

import Foundation

struct SimulatorRuntimesResponse: Codable, Hashable {
    let runtimes: [SimulatorRuntime]
}

struct SimulatorRuntime: Codable, Identifiable, Hashable {
    let isAvailable: Bool
    let version: String
    let isInternal: Bool
    let buildversion: String
    let supportedArchitectures: [String]
    let supportedDeviceTypes: [DeviceType]
    let identifier: String
    let platform: String
    let bundlePath: String
    let runtimeRoot: String
    let lastUsage: LastUsage
    let name: String

    var id: String { identifier }
}

struct DeviceType: Codable, Hashable, Identifiable {
    let bundlePath: String
    let name: String
    let identifier: String
    let productFamily: String

    var id: String { identifier }
}

struct LastUsage: Codable, Hashable {
    let arm64: String
}
