//
//  ActiveProcessesView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SwiftUI
import Supervision
import LoadableValue

struct ActiveProcessesView: View {
    @Environment(Container.self) private var container
    @Environment(WindowSceneFeature.self) private var windowSceneFeature

    @State private var activeProcessesFeature: FeatureState<ActiveProcessesBlueprint> = .idle

    private let simulatorID: Simulator.ID

    init(simulatorID: Simulator.ID) {
        self.simulatorID = simulatorID
    }

    var body: some View {
        FeatureStateView(state: $activeProcessesFeature) { feature in
            ActiveProcessesLoadableView(activeProcessesFeature: feature)
        }
        .instantiate(with: container.activeProcessesFeature(for: simulatorID))
    }
}

struct ActiveProcessesLoadableView: View {
	@Environment(WindowSceneFeature.self) private var windowSceneFeature
    private let activeProcessesFeature: ActiveProcessesFeature

    init(activeProcessesFeature: ActiveProcessesFeature) {
        self.activeProcessesFeature = activeProcessesFeature
	}

	var body: some View {
		LoadableValueView(
            activeProcessesFeature.processes,
            loaded: { processes in
                ActiveProcessesTableView(processes: processes)
            },
            failed: { _ in ProgressView() }
		)
		.onAppear {
			activeProcessesFeature.send(.retrieveProcesses)
		}
		.onDisappear {
			windowSceneFeature.send(.openActiveProcesses(nil))
		}
	}
}

private struct ActiveProcessesTableView: View {
	@State private var searchText: String = ""
	@State private var debouncedSearchText: String = ""
	let processes: [Simulator.Process]

	var filteredProcesses: [Simulator.Process] {
		processes.filter {
			if debouncedSearchText.isEmpty { return true }
			return $0.label.localizedStandardContains(debouncedSearchText)
		}
	}

	var body: some View {
		Table(filteredProcesses) {
			ActiveProcessesTableColumns()
		}
		.searchable(text: $searchText)
		.task(id: searchText) {
			try? await Task.sleep(for: .seconds(1))
			debouncedSearchText = searchText
		}
	}
}

private struct ActiveProcessesTableColumns: TableColumnContent {
	@TableColumnBuilder<Simulator.Process, Never>
	var tableColumnBody: some TableColumnContent<Simulator.Process, Never> {
		TableColumn("Process Name", value: \.label)
		TableColumn("PID", value: \.pid)
		TableColumn("Status", value: \.status)
	}
}
