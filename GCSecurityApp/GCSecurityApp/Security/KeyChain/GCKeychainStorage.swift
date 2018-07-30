//
//  KeychainStorage.swift
//  MobileBanking
//
//  Created by Guilherme Coelho on 06/04/2018.
//  Copyright © 2018 Guilherme Coelho. All rights reserved.
//

import Foundation

enum GCKeychainStorage {
  
  // MARK: - Private Properties
  
  case password(user:String)
  case email(user:String)
  case touchID(user:String)
  
  var keyChain:KeychainWrapper! {
    
    switch self {
      
    case .password, .email, .touchID :
      
      let service = "UserInfo"
      //let group = SecurityManager.shared.reveal(bytes: BSConstants.Security.mobileGroup)
      
      return KeychainWrapper(serviceName: service)
    }
  }
  
  var key:String {
    
    switch self {
      
    case .password(let user):
      return  user + "_Password"
      
    case .email(let user):
      return user + "_TouchID"
      
    case .touchID(let user):
      return user + "_Email"
    }
    
  }
  
  var errorMessage:String {
    
    switch self {
      
    case .password, .email, .touchID:
      return "Error ao acessar o KeyChain."
    }
    
  }
  
  func save(value:String) -> String? {
    
    if keyChain.set(value,
                    forKey: key,
                    withAccessibility: KeychainItemAccessibility.whenUnlockedThisDeviceOnly ) {
      // Keychain item is saved successfully
      return nil
      
    } else {
      // Report error
      return errorMessage
    }
  }
  
  // MARK: - Get
  
  func get() -> (key:String?,error:String?) {
    
    if let value = keyChain.string(forKey: key ) {
      // Keychain item is saved successfully
      return (value,nil)
      
    } else {
      // Report error
      return (nil,errorMessage)
    }
  }
  
}
