//
//  File.swift
//  Jodem Sim
//
//  Created by John Demirci on 8/17/25.
//

import Foundation

struct File: Identifiable, Hashable {
    let creationDate: Date?
    var id: URL {
        url
    }
    let isDirectory: Bool
    let modificationDate: Date?
    let name: String
    let size: Int?
    let url: URL
}
