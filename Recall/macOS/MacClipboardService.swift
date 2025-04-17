//
//  macOSClipboardService.swift
//  Recall
//
//  Created by Daksh Kaushik on 11/04/25.
//

import Foundation
import AppKit
class MacClipboardService {
    func getClipboardText() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }
}
