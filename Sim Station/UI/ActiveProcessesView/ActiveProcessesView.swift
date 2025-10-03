//
//  ActiveProcessesView.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import SwiftUI

struct ActiveProcessesLoadableView: View {
	@Environment(GlobalStore.self) private var globalStore
	private let activeProcessesStore: ActiveProcessesStore

	init(activeProcessesStore: ActiveProcessesStore) {
		self.activeProcessesStore = activeProcessesStore
	}

	var body: some View {
		LoadableValueView(
			loadableValue: activeProcessesStore.processes,
			loadedView: { processes in
				ActiveProcessesView(processes: processes)
			},
			loadingView: { ProgressView() }
		)
		.onAppear {
			activeProcessesStore.send(.retrieveProcesses)
		}
		.onDisappear {
			globalStore.send(.openActiveProcesses(nil))
		}
	}
}

private struct ActiveProcessesView: View {
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
