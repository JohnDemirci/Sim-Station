//
//  MenuBarListView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SwiftUI
import Supervision

struct MenuBarListView: View {
	@Environment(Container.self) private var container
	@Environment(WindowSceneFeature.self) private var windowSceneFeature

    @State private var simulatorFeature: FeatureState<SimulatorBlueprint> = .idle

	var body: some View {
        FeatureStateView(state: $simulatorFeature) { feature in
            VStack(spacing: 10) {
                SimulatorListVStackView()
                    .environment(feature)

                CreateSimulatorButtonView()
            }
            .padding()
        }
        .instantiate(with: container.simulatorFeature())
	}
}

private struct SimulatorListVStackView: View {
    @Environment(SimulatorFeature.self) private var simulatorFeature
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            SimulatorListExpandingButtonView(isExpanded: $isExpanded)

            if isExpanded {
                SimulatorListLoadableView(simulatorFeature: simulatorFeature)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            simulatorFeature.send(.retrieveSimulators)
        }
    }
}

private struct CreateSimulatorButtonView: View {
    @Environment(WindowSceneFeature.self) private var windowSceneFeature

    var body: some View {
        Button {
            windowSceneFeature.send(.openCreateSimulator)
        } label: {
            CreateSimulatorButtonLabelView()
        }
        .buttonStyle(.glass)
    }
}

private struct CreateSimulatorButtonLabelView: View {
    var body: some View {
        HStack {
            Image(systemName: "plus.circle")

            Text("Create Simulator")
                .font(.title3)
                .fontWeight(.light)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SimulatorListExpandingButtonView: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            SimulatorsListExpandingButtonLabelView()
        }
        .buttonStyle(.glass)
    }
}

private struct SimulatorsListExpandingButtonLabelView: View {
    var body: some View {
        HStack {
            Image(systemName: "iphone")
                .font(.largeTitle)

            Text("Simulators")
                .font(.title3)
                .fontWeight(.light)
        }
        .frame(maxWidth: .infinity)
    }
}
