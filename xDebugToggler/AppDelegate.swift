//
//  AppDelegate.swift
//  xDebug Toggler
//
//  Created by Yunus Emre Deligöz on 14.06.2020.
//  Copyright © 2020 Yunus Emre Deligöz. All rights reserved.
//

import Cocoa
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var statusBarItem: NSStatusItem!
    
    var statusBarMenu: NSMenu!
    
    var shortcut: MASShortcut?
    
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
        
        self.shortcut = XDebugManager.getShortcut()
        
        self.watchShortcutKeyChanges()
        
        XDebugManager.registerServiceSettings()
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
        let status = XDebugManager.xDebugStatus()
        
        if status == nil {
            XDebugManager.alertNotFound()
            self.openSettings()
        } else {
            self.xDebugStatus = status
            self.setIcon()
        }
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
        statusBarItem.button?.image = NSImage(named:NSImage.Name("wait"))
        
        XDebugManager.toggleXDebug()
        
        self.xDebugStatus.toggle()
    }
    
    @objc func openSettings() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else { return }
        vc.callbackClosure = { [weak self] in
            self?.checkXDebugStatus()
        }
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .semitransient
        popoverView.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
    }
    
    @objc func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    func watchShortcutKeyChanges() {
        if self.shortcut != nil {
            MASShortcutMonitor.shared()?.register(self.shortcut, withAction: self.toggleXDebug)
        } else {
            MASShortcutMonitor.shared()?.unregisterAllShortcuts()
        }
    }
}
