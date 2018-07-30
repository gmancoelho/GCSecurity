/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import LocalAuthentication

enum BiometricType {
  case none
  case touchID
  case faceID
}

enum BiometricErros:Error {
  
  case failed
  case canceled
  case notAvailable
  case locked
  case notSupported
  
  var errorMessage:String {
    switch self {
      
    case .failed:
      return "Ops! Tente novamente."
      
    case .canceled:
      return ""
      
    case .notAvailable, .notSupported:
      return "O seu dispositivo não possui suporte para autenticação biométrica"
      
    case .locked:
      return "Autenticação biométrica não disponível"
      
    }
  }
  
}

class BiometricIDAuth {
  
  let context = LAContext()
  
  func biometricType() -> BiometricType {
    
    context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    
    if #available(iOS 11.0, *) {
      switch context.biometryType {
      case .none:
        return .none
      case .touchID:
        return .touchID
      case .faceID:
        return .faceID
      }
    } else {
      return .touchID
    }
    
  }
  
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func authenticateUser(reason:String, completion: @escaping (BiometricErros?) -> Void) {
    
    guard canEvaluatePolicy() else {
      completion(BiometricErros.notAvailable)
      return
    }
    
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                           localizedReason: reason) { (success, evaluateError) in
                            if success {
                              
                              DispatchQueue.main.async {
                                // User authenticated successfully, take appropriate action
                                completion(nil)
                              }
                              
                            } else {
                              
                              if #available(iOS 11.0, *) {
                                switch evaluateError {
                                  
                                case LAError.authenticationFailed?:
                                  completion(BiometricErros.failed)
                                case LAError.userCancel?, LAError.userFallback?:
                                  completion(BiometricErros.canceled)
                                case LAError.biometryLockout?:
                                  completion(BiometricErros.locked)
                                default:
                                  completion(BiometricErros.notAvailable)
                                  
                                }
                                
                              } else {
                                
                                switch evaluateError {
                                  
                                case LAError.authenticationFailed?:
                                  completion(BiometricErros.failed)
                                case LAError.userCancel?, LAError.userFallback?:
                                  completion(BiometricErros.canceled)
                                default:
                                  completion(BiometricErros.notAvailable)
                                  
                                }
                              }
                            }
    }
  }
}
