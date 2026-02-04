//
//  Item.swift
//  FinanceTracker
//
//  Created by Yash Kulkarni on 04/02/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
