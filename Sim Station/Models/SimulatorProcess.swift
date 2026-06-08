//
//  SimulatorProcess.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/26/25.
//

extension Simulator {
    struct Process: Identifiable, Hashable {
        let label: String
        let pid: String
        let status: String

        var id: String {
            "\(pid)\(status)\(label)"
        }
    }
}
