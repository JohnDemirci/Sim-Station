//
//  CreateSimulatorView.swift
//  Sim Station
//
//  Created by John Demirci on 9/10/25.
//


import SwiftUI
import Supervision
import LoadableValue

struct CreateSimulatorView: View {
    @Environment(Container.self) private var container
    @Environment(WindowSceneFeature.self) private var windowSceneFeature
    @State private var createSimulatorFeatureState: CreateSimulatorFeatureState = .idle

    var body: some View {
        FeatureStateView(state: $createSimulatorFeatureState) { feature in
            CreateSimulatorLoadableView()
                .environment(feature)
        }
        .instantiate(with: container.createSimulatorFeature())
    }
}

struct CreateSimulatorLoadableView: View {
    @Environment(Container.self) private var container
	@Environment(WindowSceneFeature.self) private var windowSceneFeature
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	var body: some View {
		LoadableValueView(
            createSimulatorFeature.runtimes,
            loaded: { runtimes in
                CreateSimulatorStackView(runtimes: runtimes)
            },
            failed: { _ in ProgressView() }
		)
		.onAppear {
            createSimulatorFeature.send(.retrieveRuntimes)
		}
		.onDisappear {
			windowSceneFeature.send(.dismissCreateSimulator)
		}
	}
}

private struct CreateSimulatorStackView: View {
    @Environment(CreateSimulatorFeature.self) private var createSimulatorFeature

	private let runtimes: [SimulatorRuntime]

	init(runtimes: [SimulatorRuntime]) {
		self.runtimes = runtimes
	}

	var body: some View {
		VStack {
			switch createSimulatorFeature.tab {
			case .runtimes:
				CreateSimulatorRuntimeSelectionView(
					createSimulatorFeature: createSimulatorFeature,
					runtimes: runtimes
				)
			case .deviceType:
				CreateSimulatorDeviceTypesView(
                    createSimulatorFeature: createSimulatorFeature,
					deviceTypes: createSimulatorFeature.selectedRuntime?.supportedDeviceTypes ?? []
				)
			case .nameSelection:
				SimulatorNameSelectionView(createSimulatorFeature: createSimulatorFeature,)
			case .overview:
				CreateSimulatorOverviewView(createSimulatorFeature: createSimulatorFeature,)
			case .success:
				CreateSimulatorSuccessView(createSimulatorFeature: createSimulatorFeature,)
			case .failure(let message):
				Text(message)
			}
		}
	}
}
