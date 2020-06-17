//
//  ViewController.swift
//  xDebug Toggler
//
//  Created by Yunus Emre Deligöz on 14.06.2020.
//  Copyright © 2020 Yunus Emre Deligöz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    var callbackClosure: (() -> Void)?
    
    @IBOutlet weak var xDebugFilePath: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xDebugFilePath.stringValue = UserDefaults.standard.string(forKey: "xDebugFilePath") ?? ""
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
            
            self.closeSettings(sender)
        } else {
            XDebugManager.alertSetFilePath()
        }
    }
    
    @IBAction func closeSettings(_ sender: Any) {
        self.view.window?.performClose(sender)
    }
    
    
}

