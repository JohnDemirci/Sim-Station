//
//  Simulator.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation
import SwiftUI

struct Simulator: Codable, Hashable, Identifiable {
    var dataPath: String?
    var dataPathSize: Int?
    var deviceTypeIdentifier: String?
    var isAvailable: Bool?
    var logPath: String?
    var name: String?
    var os: OS.Name?
    var state: State?
    var udid: String?

    init(
        dataPath: String? = nil,
        dataPathSize: Int? = nil,
        deviceTypeIdentifier: String? = nil,
        isAvailable: Bool? = nil,
        logPath: String? = nil,
        name: String? = nil,
        os: OS.Name? = nil,
        state: State? = nil,
        udid: String? = nil
    ) {
        self.dataPath = dataPath
        self.dataPathSize = dataPathSize
        self.deviceTypeIdentifier = deviceTypeIdentifier
        self.isAvailable = isAvailable
        self.logPath = logPath
        self.name = name
        self.os = os
        self.state = state
        self.udid = udid
    }

    var id: String { udid ?? UUID().uuidString }
}

extension Simulator {
    enum State: String, Codable, Sendable {
        case booted = "Booted"
        case shutdown = "Shutdown"

        init?(rawValue: String) {
            if rawValue.lowercased() == "shutdown" {
                self = .shutdown
            } else if rawValue.lowercased() == "booted" {
                self = .booted
            } else {
                return nil
            }
        }

        func opposite() -> State {
            switch self {
            case .booted:
                return .shutdown
            case .shutdown:
                return .booted
            }
        }
    }
    
    struct Application: Codable, Identifiable, Hashable {
        let ApplicationType: String
        let Bundle: String
        let CFBundleDisplayName: String
        let CFBundleExecutable: String
        let CFBundleIdentifier: String
        let CFBundleName: String
        let CFBundleVersion: String
        let DataContainer: String?
        let Path: String
        let GroupContainers: [String: String]?
        let SBAppTags: [String]?

        var id: String {
            CFBundleIdentifier
        }
    }
}
