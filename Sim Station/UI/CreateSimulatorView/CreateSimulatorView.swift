//
//  CreateSimulatorView.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//

import SSM
import SwiftUI

struct CreateSimulatorLoadableView: View {
	@Environment(GlobalStore.self) private var globalStore
	private let createSimulatorStore: CreateSimulatorStore

	init(createSimulatorStore: CreateSimulatorStore) {
		self.createSimulatorStore = createSimulatorStore
	}

	var body: some View {
		LoadableValueView(
			loadableValue: createSimulatorStore.runtimes,
			loadedView: { runtimes in
				CreateSimulatorView(
					createSimulatorStore: createSimulatorStore,
					runtimes: runtimes
				)
			},
			loadingView: { ProgressView() }
		)
		.onAppear {
			createSimulatorStore.send(.retrieveRuntimes)
		}
		.onDisappear {
			globalStore.send(.dismissCreateSimulator)
		}
	}
}

private struct CreateSimulatorView: View {
	private let createSimulatorStore: CreateSimulatorStore
	private let runtimes: [SimulatorRuntime]

	init(createSimulatorStore: CreateSimulatorStore, runtimes: [SimulatorRuntime]) {
		self.createSimulatorStore = createSimulatorStore
		self.runtimes = runtimes
	}

	var body: some View {
		VStack {
			switch createSimulatorStore.tab {
			case .runtimes:
				CreateSimulatorRuntimeSelectionView(
					createSimulatorStore: createSimulatorStore,
					runtimes: runtimes
				)
			case .deviceType:
				CreateSimulatorDeviceTypesView(
					createSimulatorStore: createSimulatorStore,
					deviceTypes: createSimulatorStore.selectedRuntime?.supportedDeviceTypes ?? []
				)
			case .nameSelection:
				SimulatorNameSelectionView(createSimulatorStore: createSimulatorStore)
			case .overview:
				CreateSimulatorOverviewView(createSimulatorStore: createSimulatorStore)
			case .success:
				CreateSimulatorSuccessView(createSimulatorStore: createSimulatorStore)
			case .failure(let message):
				Text(message)
			}
		}
	}
}
