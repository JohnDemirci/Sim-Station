//
//  InstalledApplicationsReducer.swift
//  Sim Station
//
//  Created by John Demirci on 9/30/25.
//

import Foundation
import SSM
import SwiftUI

struct InstalledApplicationsReducer: Reducer {
	struct State: Identifiable {
		let id: Simulator.ID
		var applications: LoadableValue<[Simulator.Application], Error> = .idle
	}

	struct Environment {
		let retrieveInstalledApplicationsCommand: (Simulator.ID) -> RetrieveInstalledApplicationsCommand
		let workspace: NSWorkspace
	}

	enum Request {
		case openApplicationDataFolder(Simulator.Application)
		case openUserDefaults(Simulator.Application)
		case retrieve
	}

	func reduce(store: Store<InstalledApplicationsReducer>, request: Request) async {
		switch request {
		case .openApplicationDataFolder(let application):
			guard
				let container = application.DataContainer,
				let url = URL(string: container)
			else { return }
			_ = withEnvironment(store: store, keyPath: \.workspace) {
				$0.open(url)
			}

		case .openUserDefaults(let application):
			guard let container = application.DataContainer else {
				assertionFailure("show error")
				return
			}

			let string = "\(application.CFBundleIdentifier).plist"

			guard let containerURL = URL(string: container) else {
				assertionFailure("show error")
				return
			}

			let preferencesURL = containerURL
				.appendingPathComponent("Library")
				.appendingPathComponent("Preferences")
				.appendingPathComponent(string)

			_ = withEnvironment(store: store, keyPath: \.workspace) {
				$0.open(preferencesURL)
			}

		case .retrieve:
			await load(store: store, keyPath: \.applications) {
				try await $0.retrieveInstalledApplicationsCommand(store.state.id)
					.run()
			}
		}
	}
}

extension StoreContrainer where Environment == AppEnvironment {
	func installedAppsStore(_ id: Simulator.ID) -> Store<InstalledApplicationsReducer> {
		store(state: InstalledApplicationsReducer.State(id: id)) {
			InstalledApplicationsReducer.Environment(
				retrieveInstalledApplicationsCommand: $0.retrieveInstalledApplicationsCommand,
				workspace: $0.workspace
			)
		}
	}
}
