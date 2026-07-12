//
//  WindowSceneBlueprintTests.swift
//  Sim Station
//
//  Created by John Demirci on 6/8/26.
//

import Testing
import Supervision
@testable import Sim_Station

struct WindowSceneBlueprintTests {
    @Test
    func `openCreateSimulator action sets the openCreateSimulator state value to EquatableVoid from nil`() throws {
        let sut = Tester<WindowSceneBlueprint>(initialState: WindowSceneBlueprint.State())

        #expect(sut.state.openCreateSimulator.value == nil)

        try sut.send(.openCreateSimulator) { state in
            #expect(state.openCreateSimulator.value == EquatableVoid())
        }
        .assertDone()
    }

    @Test
    func `dismissCreateSimulator action sets openCreateSimulator value to nil`() throws {
        let sut = Tester<WindowSceneBlueprint>(
            initialState: WindowSceneBlueprint.State(
                openCreateSimulator: WindowID(.createSimulator, value: EquatableVoid())
            )
        )

        #expect(sut.state.openCreateSimulator.value == EquatableVoid())

        try sut.send(.dismissCreateSimulator) { state in
            #expect(sut.state.openCreateSimulator.value == nil)
        }
        .assertDone()
    }

    @Test(arguments: ["one", "two", "three", nil])
    func `openActiveProcesses action sets the openActiveProcesses state value to given Simulator.ID from nil`(_ id: Simulator.ID?) throws {
        let sut = Tester<WindowSceneBlueprint>(initialState: WindowSceneBlueprint.State())

        #expect(sut.state.openActiveProcesses.value == nil)

        try sut.send(.openActiveProcesses(id)) { state in
            #expect(state.openActiveProcesses.value == id)
        }
        .assertDone()
    }

    @Test(arguments: ["one", "two", "three", nil])
    func `openBatteryStatus action sets the openBatteryStatus state value to given Simulator.ID from nil`(_ id: Simulator.ID?) throws {
        let sut = Tester<WindowSceneBlueprint>(initialState: WindowSceneBlueprint.State())

        #expect(sut.state.openBatteryStatus.value == nil)

        try sut.send(.openBatteryStatus(id)) { state in
            #expect(state.openBatteryStatus.value == id)
        }
        .assertDone()
    }

    @Test(arguments: ["one", "two", "three", nil])
    func `openSimulatorInformation action sets the openSimulatorInformation state value to given Simulator from nil`(_ id: Simulator.ID?) throws {
        let sut = Tester<WindowSceneBlueprint>(initialState: WindowSceneBlueprint.State())

        let simulator: Simulator? = if let id {
            Simulator(udid: id)
        } else {
            nil
        }

        #expect(sut.state.openSimulatorInformation.value == nil)

        try sut.send(.openSimulatorInformation(simulator)) { state in
            #expect(state.openSimulatorInformation.value == simulator)
        }
        .assertDone()
    }
}
