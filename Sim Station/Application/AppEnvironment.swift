//
//  AppEnvironment.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM
import SwiftUI

struct AppEnvironment {
	let createSimulatorCommand: (CreateSimulatorCommand.Parameters) -> CreateSimulatorCommand
	let broadcast: BroadcastStudio
	let deleteSimulatorCommand: (Simulator.ID) -> DeleteSimulatorShellCommand
	let openSimulatorCommand: (Simulator.ID) -> OpenSimulatorShellCommand
	let retrieveActiveProcessesCommand: (Simulator.ID) -> RetrieveActiveProcessesShellCommand
	let retrieveBatteryStateCommand: (Simulator.ID) -> RetrieveBatteryStateCommand
	let retrieveInstalledApplicationsCommand: (Simulator.ID) -> RetrieveInstalledApplicationsCommand
	let retrieveSimulatorCommand: RetrieveSimulatorsCommand
	let retrieveSimulatorRuntimesCommand: RetrieveSimulatorRuntimesCommand
	let setNewBatteryStateCommand: (Simulator.ID, BatteryState) -> SetNewBatteryStateCommand
	let shutdownSimulatorCommand: (Simulator.ID) -> ShutdownSimulatorShellCommand
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
