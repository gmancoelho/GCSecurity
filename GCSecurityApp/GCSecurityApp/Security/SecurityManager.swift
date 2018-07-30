//
//  SecurityManager.swift
//  MobileBanking
//
//  Created by Guilherme Coelho on 23/03/2018.
//  Copyright © 2018 Guilherme Coelho. All rights reserved.
//

import Foundation

final class SecurityManager {

  // MARK: - Properties

  let salt = [AppDelegate.self, NSObject.self, NSString.self]

  private var obfs:Obfuscator!
  
  // Init

  private init() {

    obfs = Obfuscator(withSalt: salt)

  }

  // MARK: Shared Instance

  static let shared: SecurityManager = {
    let instance = SecurityManager()
    // setup code
    return instance
  }()

  // MARK: - Obfuscator

  public func obfuscate(message:String) -> [UInt8] {

    let bytes = obfs.bytesByObfuscatingString(string: message)

    return bytes
  }

  public func reveal(bytes: [UInt8]) -> String {

    let value = obfs.reveal(key: bytes)

    return value
  }

  // MARK: - Public Methods
  
  public func detectSecurityIssues() {

    if isJailbroken() {
      dump("Device is compromised")
      self.deleteAppData()
    }
    
  }

  /// Detele user data

  func deleteAppData() {

    // Delete UserDefaults
    resetDefaults()

    // Delete Keychain
    resetKeychain()
  }

  private func resetKeychain() {

    deleteAllKeysForSecClass(kSecClassGenericPassword)
    deleteAllKeysForSecClass(kSecClassInternetPassword)
    deleteAllKeysForSecClass(kSecClassCertificate)
    deleteAllKeysForSecClass(kSecClassKey)
    deleteAllKeysForSecClass(kSecClassIdentity)

  }

  private func deleteAllKeysForSecClass(_ secClass: CFTypeRef) {
    let dict: [NSString : Any] = [kSecClass : secClass]
    let result = SecItemDelete(dict as CFDictionary)
    assert(result == noErr || result == errSecItemNotFound, "Error deleting keychain data (\(result))")
  }

  private func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
      defaults.removeObject(forKey: key)
    }
  }
  
  // MARK: - Check Device
  
  func isJailbroken() -> Bool {
    
    #if TARGET_IPHONE_SIMULATOR
      return false
    #endif
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
      fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
      fileManager.fileExists(atPath: "/bin/bash") ||
      fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
      fileManager.fileExists(atPath: "/etc/apt") ||
      fileManager.fileExists(atPath: "/usr/bin/ssh") {
      return true
    }
    
    if canOpen(path: "/Applications/Cydia.app") ||
      canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
      canOpen(path: "/bin/bash") ||
      canOpen(path: "/usr/sbin/sshd") ||
      canOpen(path: "/etc/apt") ||
      canOpen(path: "/usr/bin/ssh") {
      return true
    }
    
    let path = "/private/" + NSUUID().uuidString
    
    do {
      try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
      try fileManager.removeItem(atPath: path)
      return true
    } catch {
      return false
    }
    
  }
  
  func canOpen(path: String) -> Bool {
    let file = fopen(path, "r")
    guard file != nil else { return false }
    fclose(file)
    return true
  }
  
}
