//
//  AppEnvironment.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM
import SwiftUI

struct AppEnvironment: Sendable {
	let createSimulatorCommand: @Sendable (CreateSimulatorCommand.Parameters) -> CreateSimulatorCommand
	let broadcast: BroadcastStudio
	let deleteSimulatorCommand: @Sendable (Simulator.ID) -> DeleteSimulatorShellCommand
	let openSimulatorCommand: @Sendable (Simulator.ID) -> OpenSimulatorShellCommand
	let retrieveActiveProcessesCommand: @Sendable (Simulator.ID) -> RetrieveActiveProcessesShellCommand
	let retrieveBatteryStateCommand: @Sendable (Simulator.ID) -> RetrieveBatteryStateCommand
	let retrieveInstalledApplicationsCommand: @Sendable (Simulator.ID) -> RetrieveInstalledApplicationsCommand
	let retrieveSimulatorCommand: RetrieveSimulatorsCommand
	let retrieveSimulatorRuntimesCommand: RetrieveSimulatorRuntimesCommand
	let setNewBatteryStateCommand: @Sendable (Simulator.ID, BatteryState) -> SetNewBatteryStateCommand
	let shutdownSimulatorCommand: @Sendable (Simulator.ID) -> ShutdownSimulatorShellCommand
	let workspace: NSWorkspace

	init() {
		self.createSimulatorCommand = { CreateSimulatorCommand($0) }
		self.broadcast = .shared
		self.deleteSimulatorCommand = { DeleteSimulatorShellCommand($0) }
		self.openSimulatorCommand = { OpenSimulatorShellCommand($0) }
		self.retrieveActiveProcessesCommand = { RetrieveActiveProcessesShellCommand($0) }
		self.retrieveBatteryStateCommand = { RetrieveBatteryStateCommand($0) }
		self.retrieveInstalledApplicationsCommand = { RetrieveInstalledApplicationsCommand($0) }
		self.retrieveSimulatorCommand = RetrieveSimulatorsCommand()
		self.retrieveSimulatorRuntimesCommand = RetrieveSimulatorRuntimesCommand()
		self.setNewBatteryStateCommand = { SetNewBatteryStateCommand(simulatorID: $0, state: $1) }
		self.shutdownSimulatorCommand = { ShutdownSimulatorShellCommand($0) }
		self.workspace = .shared
	}
}

extension NSWorkspace: @unchecked @retroactive Sendable {}
