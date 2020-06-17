//
//  XDebugManager.swift
//  xDebug Toggler
//
//  Created by Yunus Emre Deligöz on 17.06.2020.
//  Copyright © 2020 Yunus Emre Deligöz. All rights reserved.
//

import Cocoa

class XDebugManager: NSObject {
    
    class func getFilePathFromDefaults() -> String? {
        return UserDefaults.standard.string(forKey: "xDebugFilePath")
    }
    
    class func isFirstStart() -> Bool {
        if (UserDefaults.standard.string(forKey: "xDebugFilePath") != nil) {
            return false
        }
        
        return true
    }
    
    class func saveFilePath(path: String) {
        UserDefaults.standard.set(path, forKey: "xDebugFilePath")
    }
    
    class func xDebugStatus() -> Bool? {
        if self.isFirstStart() {
            // Try fo find file
            let path = self.probableXDebugFileURL()
            
            // Enabled state
            if FileManager.default.fileExists(atPath: path.path) {
                self.saveFilePath(path: path.path)
                
                return true
            }
            
            // Disabled state
            if FileManager.default.fileExists(atPath: "\(path.path).disabled") {
                self.saveFilePath(path: path.path)
                
                return false
            }
            
            
            // No file found
            return nil
        }
        
        // Read from user defaults
        let filePath = self.getFilePathFromDefaults()
        
        if (filePath == nil) {
            self.alertSetFilePath()
        }
        
        // Check if it exists as is
        if FileManager.default.fileExists(atPath: filePath!) {
            return true
        }
        
        // Check if it exist with '.disabled' extension
        if FileManager.default.fileExists(atPath: "\(filePath!).disabled") {
            return false
        }
        
        // The file path on defaults is not exists -> must be set from settings again
        return nil
    }
 
    class func alertNotFound() {
        let alert = NSAlert()
        alert.messageText = "ext-xdebug.ini file could not be found."
        alert.informativeText = "Right click the app status bar icon and choose settings to set the file path."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
    
    class func alertSetFilePath() {
        let alert = NSAlert()
        alert.messageText = "ext-xdebug.ini file could not be found at the given path."
        alert.informativeText = "Please check the given path or search for ext-xdebug.ini using the 'Find' button."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
    
    class func alertCannotToggle() {
        let alert = NSAlert()
        alert.messageText = "Cannot toggle xDebug status"
        alert.informativeText = "Probably cannot find the ext-xdebug-ini file. Please right click the app status bar icon and choose settings to set the file path."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
    
    class func findPHPVersion() -> String {
        let phpVersion = try? FileManager.default.contentsOfDirectory(atPath: "/usr/local/etc/php/").sorted().last(where: { $0 != ".DS_Store"})
        
        return phpVersion ?? "7.4"
    }
    
    class func probableXDebugFileURL() -> URL {
        return NSURL.fileURL(withPath: "/usr/local/etc/php/\(self.findPHPVersion())/conf.d/ext-xdebug.ini")
    }
    
    class func toggleXDebug() {
        do {
            let path = self.getFilePathFromDefaults()!
            
            if self.xDebugStatus() == true {
                try FileManager.default.moveItem(atPath: path, toPath: path + ".disabled")
            } else {
                try FileManager.default.moveItem(atPath: path + ".disabled", toPath: path)
            }
        } catch {
            self.alertCannotToggle()
        }
    }
}
