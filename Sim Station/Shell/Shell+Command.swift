//
//  Shell+Command.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation
import OrderedCollections

protocol ShellCommand: Sendable {
    associatedtype Result
    var path: ShellCommandPath { get }
    var tokens: [ShellCommandToken] { get }
    func run() async throws -> Result
}

struct ShellExecutionError: Error, CustomStringConvertible {
    var description: String
}

extension ShellCommand {
    func build() -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path.rawValue)
        process.arguments = tokens.map(\.rawValue)
        return process
    }

    @discardableResult
    func rawData(for process: Process) async throws -> Data {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()

        async let outputData = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
                continuation.resume(returning: data)
            }
        }

        // Read stderr to prevent the "shutdown: NOT super-user" message from being logged
        async let errorData = await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                continuation.resume(returning: errorData)
            }
        }

        if let stringRepresentation = await String(
            data: errorData,
            encoding: .utf8
        ) {
            if !stringRepresentation.isEmpty {
                throw ShellExecutionError(description: stringRepresentation)
            }
        }

        process.waitUntilExit()

        return await outputData
    }
}

enum ShellCommandToken {
    case boot
    case create
    case custom(String)
    case delete
    case devices
    case deviceTypes
    case doubleDashArgs
    case doubleDashJson
    case erase
    case list
    case listApps
    case location
    case override
    case runtimes
    case shutdown
    case set
    case simctl
    case simulator
    case statusBar

    var rawValue: String {
        switch self {
        case .boot:
            "boot"
        case .create:
            "create"
        case .custom(let custom):
            custom
        case .delete:
            "delete"
        case .devices:
            "devices"
        case .deviceTypes:
            "devicetypes"
        case .doubleDashArgs:
            "--args"
        case .erase:
            "erase"
        case .doubleDashJson:
            "--json"
        case .list:
            "list"
        case .listApps:
            "listapps"
        case .location:
            "location"
        case .override:
            "override"
        case .runtimes:
            "runtimes"
        case .shutdown:
            "shutdown"
        case .set:
            "set"
        case .simctl:
            "simctl"
        case .simulator:
            "Simulator"
        case .statusBar:
            "status_bar"
        }
    }
}

enum ShellCommandPath: String {
    case bash = "/bin/bash"
    case open = "/usr/bin/open"
    case xcrun = "/usr/bin/xcrun"
}

