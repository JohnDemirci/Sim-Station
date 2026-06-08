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
    @State private var isExpanded: Bool = false

	var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        FeatureStateView(state: $simulatorFeature) { feature in
            VStack(spacing: 10) {
                SimulatorListVStackView()
                    .environment(feature)

                Button {
                    windowSceneFeature.send(.openCreateSimulator)
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")

                        Text("Create Simulator")
                            .font(.title3)
                            .fontWeight(.light)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            .padding()
        }
        .instantiate(with: container.simulatorFeature())
	}
}

private struct SimulatorListVStackView: View {
    @Environment(SimulatorFeature.self) private var simulatorFeature
    @State private var isExpanded: Bool = false
    
    #if DEBUG
    @State private var simulator_retrieve_count: Int = 0
    #endif
    
    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "iphone")
                        .font(.largeTitle)
                    
                    Text("Simulators")
                        .font(.title3)
                        .fontWeight(.light)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            
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

#Preview {
    MenuBarListView()
}
