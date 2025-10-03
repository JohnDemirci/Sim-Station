//
//  WindowID.swift
//  Sim Station
//
//  Created by John Demirci on 9/9/25.
//

import Foundation

struct WindowID<T: Equatable>: Identifiable, Equatable {
	let id: String
	var value: T?

	init(
		_ id: String,
		value: T? = nil
	) {
		self.id = id
		self.value = value
	}
}
