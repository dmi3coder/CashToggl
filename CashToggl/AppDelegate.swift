//
//  AppDelegate.swift
//  CashToggl
//
//  Created by Dmitry Chaban on 28.06.2020.
//  Copyright © 2020 Donau Tech. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    const let HOURLY_RATE = 0.0; // REPLACE YOUR VALUE HERE

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView()
//
//        // Create the window and set the content view. 
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "0.00$"
        var lastUsageTime : Date? = nil
        var earning: Bool = false
        
        
        
        TogglApi.getEntriesForToday(from: Date().startOfDay(), to: Date().endOfDay()) {
            lastUsageTime = $0;
            earning = $1
        }
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval.init(exactly: 0.1)!, repeats: true) { _ in
            let lazyTime = Date().timeIntervalSince(lastUsageTime ?? Date())
            let moneyWasted = String(format: "%.4f", lazyTime / 60.0 / 60.0 * HOURLY_RATE)
            self.statusItem?.button?.title = "\(moneyWasted)$"
            self.statusItem?.button?.contentTintColor = earning ? NSColor.green : NSColor.red
        }
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval.init(exactly: 10)!, repeats: true) { _ in
            TogglApi.getEntriesForToday(from: Date().startOfDay(), to: Date().endOfDay()) {
                lastUsageTime = $0;
                earning = $1
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    func endOfDay() -> Date {
        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
}
