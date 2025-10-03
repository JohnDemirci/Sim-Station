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

	var body: some View {
		Menu {
			SimulatorListLoadableView(
				simulatorStore: container.simulatorStore()
			)
		} label: {
			Text("Simulators")
				.font(.title3)
				.fontWeight(.light)
		}

		Button(
			action: {
				globalStore.send(.openCreateSimulator(.init()))
			},
			label: {
				Text("Create Simulator")
					.font(.title3)
					.fontWeight(.light)
			}
		)
	}
}
