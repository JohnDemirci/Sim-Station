//
//  HashIdentifiable.swift
//  Jodem Sim
//
//  Created by John Demirci on 7/1/25.
//

import Foundation

/// A protocol that conforms to Hashable and Identifiable protocols
/// The intended usecase of this protocol to use self as a ``AnyHashable`` identifier
protocol HashIdentifiable: Hashable, Identifiable {}

extension HashIdentifiable {
    var id: AnyHashable { self }
}
