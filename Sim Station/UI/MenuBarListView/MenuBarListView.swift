//
//  MenuBarListView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SSM
import SwiftUI

struct MenuBarListView: View {
	@Environment(StoreContrainer<AppEnvironment>.self) private var container
	@Environment(GlobalStore.self) private var globalStore
    @State private var isExpanded: Bool = false

	var body: some View {
        VStack(spacing: 10) {
            SimulatorListVStackView(simulatorStore: container.simulatorStore())
            
            Button {
                globalStore.send(.openCreateSimulator)
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
}

private struct SimulatorListVStackView: View {
    @State private var isExpanded: Bool = false
    let simulatorStore: SimulatorStore
    
    #if DEBUG
    @State private var simulator_retrieve_count: Int = 0
    #endif
    
    var body: some View {
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
                SimulatorListLoadableView(simulatorStore: simulatorStore)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            #if DEBUG
            simulator_retrieve_count += 1
            dump("simulator retrieve count is \(simulator_retrieve_count)")
            #endif
            simulatorStore.send(.retrieveSimulators)
        }
    }
}

#Preview {
    MenuBarListView()
}
