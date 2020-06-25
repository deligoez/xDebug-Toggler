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
    @IBOutlet weak var phpService: NSButton!
    @IBOutlet weak var nginxService: NSButton!
    @IBOutlet weak var redisService: NSButton!
    @IBOutlet weak var mysqlService: NSButton!
    @IBOutlet weak var dnsmasqService: NSButton!
    @IBOutlet weak var allServices: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xDebugFilePath.stringValue = UserDefaults.standard.string(forKey: "xDebugFilePath") ?? ""
        
        self.getShortcut()
        
        self.watchShortcutKeyChanges()
        
        self.getServiceRestarts()
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
            (FileManager.default.isReadableFile(atPath: self.xDebugFilePath.stringValue) ||
            FileManager.default.isReadableFile(atPath: self.xDebugFilePath.stringValue + ".disabled")) {
            
            // Check for disabled state
            if xDebugFilePath.stringValue.contains(".disabled") {
                UserDefaults.standard.set(self.xDebugFilePath.stringValue.replacingOccurrences(of: ".disabled", with: ""), forKey: "xDebugFilePath")
            } else {
                UserDefaults.standard.set(self.xDebugFilePath.stringValue, forKey: "xDebugFilePath")
            }
            
            // Save shortcut
            self.saveShortcut()
            
            // Save service restarts
            self.saveServiceRestarts()
            
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
    
    func saveServiceRestarts() {
        // Check if all services should have restarted
        UserDefaults.standard.set(self.allServices.state.rawValue, forKey:"serviceAll")
        
        if self.allServices.state == .on {
            UserDefaults.standard.set(NSControl.StateValue.off.rawValue, forKey:"servicePhp")
            UserDefaults.standard.set(NSControl.StateValue.off.rawValue, forKey:"serviceNginx")
            UserDefaults.standard.set(NSControl.StateValue.off.rawValue, forKey:"serviceRedis")
            UserDefaults.standard.set(NSControl.StateValue.off.rawValue, forKey:"serviceMysql")
            UserDefaults.standard.set(NSControl.StateValue.off.rawValue, forKey:"serviceDnsmasq")
        } else {
            UserDefaults.standard.set(self.phpService.state.rawValue, forKey:"servicePhp")
            UserDefaults.standard.set(self.nginxService.state.rawValue, forKey:"serviceNginx")
            UserDefaults.standard.set(self.redisService.state.rawValue, forKey:"serviceRedis")
            UserDefaults.standard.set(self.mysqlService.state.rawValue, forKey:"serviceMysql")
            UserDefaults.standard.set(self.dnsmasqService.state.rawValue, forKey:"serviceDnsmasq")
        }
    }
    
    func getServiceRestarts() {
        self.allServices.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"serviceAll"))
        self.phpService.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"servicePhp"))
        self.nginxService.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"serviceNginx"))
        self.redisService.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"serviceRedis"))
        self.mysqlService.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"serviceMysql"))
        self.dnsmasqService.state = NSControl.StateValue(UserDefaults.standard.integer(forKey:"serviceDnsmasq"))
    }
    
    @IBAction func toggleServices(_ sender: Any) {
        if self.allServices.state == .on {
            self.phpService.state = NSControl.StateValue.off
            self.nginxService.state = NSControl.StateValue.off
            self.redisService.state = NSControl.StateValue.off
            self.mysqlService.state = NSControl.StateValue.off
            self.dnsmasqService.state = NSControl.StateValue.off
        }
    }
    
    
}

