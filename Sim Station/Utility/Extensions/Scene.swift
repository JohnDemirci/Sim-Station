//
//  Scene.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SwiftUI

extension Scene {
	@SceneBuilder
	func manageWindow<K: Equatable>(
        _ windowSceneFeature: WindowSceneFeature,
		keypath: KeyPath<WindowSceneFeature.State, WindowID<K>>,
	) -> some Scene {
		onChange(of: windowSceneFeature.state[keyPath: keypath]) { old, newValue in
			let environmentValues = EnvironmentValues()
			guard newValue.value != nil else {
				environmentValues.dismissWindow(id: newValue.id)
				return
			}

			NSApplication.shared.activate(ignoringOtherApps: true)
			environmentValues.openWindow(id: newValue.id)
		}
	}
}

extension String {
	static let activeProcesses: Self = "active-processes"
	static let batteryStatus: Self = "battery-status"
	static let createSimulator: Self = "create-simulator"
	static let simulatorInformation: Self = "simulator-information"
}
