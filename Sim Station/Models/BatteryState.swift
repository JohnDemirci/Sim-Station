//
//  BatteryState.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/14/25.
//

enum BatteryChargeState: String, Hashable, Identifiable, CaseIterable {
    case charged
    case charging
    case discharging
	case unknown

    var id: String { rawValue }
}

struct BatteryState: HashIdentifiable {
    let chargeState: BatteryChargeState
    let batteryLevel: Int
}


