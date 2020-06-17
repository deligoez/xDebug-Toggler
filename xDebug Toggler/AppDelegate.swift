//
//  AppDelegate.swift
//  xDebug Toggler
//
//  Created by Yunus Emre Deligöz on 14.06.2020.
//  Copyright © 2020 Yunus Emre Deligöz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    let path = "/usr/local/etc/php/7.4/conf.d/ext-xdebug.ini"
    
    var statusBarItem: NSStatusItem!
    
    var statusBarMenu: NSMenu!
    
    var xDebugStatus: Bool! {
        didSet(value) {
            self.setIcon()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        statusBarItem.button?.action = #selector(self.statusBarButtonClicked(sender:))
        statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        checkXDebugStatus()
        
        buildMenu()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        //
    }
    
    func buildMenu() {
        statusBarMenu = NSMenu(title: "Status Bar Menu")
        statusBarMenu.delegate = self
        statusBarMenu.addItem(
            withTitle: "Toggle xDebug",
            action: #selector(AppDelegate.toggleXDebug),
            keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: "Settings...",
            action: #selector(AppDelegate.openSettings),
            keyEquivalent: "")
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: "Quit xDebug Toggler",
            action: #selector(AppDelegate.quitApplication),
            keyEquivalent: "")
    }
    
    func checkXDebugStatus() {
        self.xDebugStatus = FileManager.default.fileExists(atPath: self.path)
            ? true
            : false
    }
    
    func setIcon() {
        statusBarItem.button?.image = self.xDebugStatus
            ? NSImage(named:NSImage.Name("dark"))
            : NSImage(named:NSImage.Name("light"))
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type ==  NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
        } else {
            self.toggleXDebug()
        }
    }
    
    @objc func menuDidClose(_ menu: NSMenu) {
        statusBarItem.menu = nil
    }
    
    @objc func toggleXDebug() {
        do {
            if self.xDebugStatus == true {
                try FileManager.default.moveItem(atPath: path, toPath: path + ".disabled")
            } else {
                try FileManager.default.moveItem(atPath: path + ".disabled", toPath: path)
            }
        } catch {
            print("Can't toggle xDebug: \(error).")
            
            let alert = NSAlert()
            alert.messageText = "ext-xdebug.ini file could not be found."
            alert.informativeText = "Right click the app status bar icon and choose settings to set the file path."
            alert.alertStyle = NSAlert.Style.warning
            alert.addButton(withTitle: "OK")
            
            alert.runModal()
        }
        
        self.xDebugStatus.toggle()
    }
    
    @objc func openSettings() {
        print("Opening Settings...")

    }
    
    @objc func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
}
