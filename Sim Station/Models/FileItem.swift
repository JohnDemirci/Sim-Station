//
//  FileItem.swift
//  Jodem Sim
//
//  Created by John Demirci on 6/20/25.
//

import Foundation

struct FileItem: Identifiable, Hashable {
    let creationDate: Date?
    let id = UUID()
    let isDirectory: Bool
    let modificationDate: Date?
    let name: String
    let size: Int?
    let url: URL
}
