//
//  ViewController.swift
//  xDebug Toggler
//
//  Created by Yunus Emre Deligöz on 14.06.2020.
//  Copyright © 2020 Yunus Emre Deligöz. All rights reserved.
//

import Cocoa
import MASShortcut

class ViewController: NSViewController {
    var callbackClosure: (() -> Void)?
    
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    @IBOutlet weak var xDebugFilePath: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xDebugFilePath.stringValue = UserDefaults.standard.string(forKey: "xDebugFilePath") ?? ""
        
        self.getShortcut()
        
        self.watchShortcutKeyChanges()
    }
    
    override func viewDidDisappear() {
        self.callbackClosure?()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func findXDebugFile(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.directoryURL = XDebugManager.probableXDebugFileURL()
        
        openPanel.begin { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                self.xDebugFilePath.stringValue = openPanel.url!.path
            }
        }
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        if  xDebugFilePath.stringValue.contains("ext-xdebug.ini") &&
            FileManager.default.isReadableFile(atPath: self.xDebugFilePath.stringValue) {
            
            // Check for disabled state
            if xDebugFilePath.stringValue.contains(".disabled") {
                UserDefaults.standard.set(self.xDebugFilePath.stringValue.replacingOccurrences(of: ".disabled", with: ""), forKey: "xDebugFilePath")
            } else {
                UserDefaults.standard.set(self.xDebugFilePath.stringValue, forKey: "xDebugFilePath")
            }
            
            // Save shortcut
            self.saveShortcut()
            
            self.closeSettings(sender)
        } else {
            XDebugManager.alertSetFilePath()
        }
    }
    
    @IBAction func closeSettings(_ sender: Any) {
        self.view.window?.performClose(sender)
    }
    
    func saveShortcut() {
        if let shortcut = self.shortcutView.shortcutValue {
            XDebugManager.saveShortcut(useModifier: Int(shortcut.modifierFlags.rawValue), useKeyCode: shortcut.keyCode)
        }
    }
    
    func getShortcut() {
        self.shortcutView.shortcutValue = XDebugManager.getShortcut()
    }
    
    func watchShortcutKeyChanges() {
        let appDelegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
        
        self.shortcutView.shortcutValueChange = { (sender) in
            
            if self.shortcutView.shortcutValue != nil {
                MASShortcutMonitor.shared().register(self.shortcutView.shortcutValue, withAction: appDelegate?.toggleXDebug)
            } else {
                MASShortcutMonitor.shared()?.unregisterAllShortcuts()
                XDebugManager.removeShortcut()
            }
        }
    }
    
    
}

