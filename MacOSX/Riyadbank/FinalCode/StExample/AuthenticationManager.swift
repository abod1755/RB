import UIKit
import LocalAuthentication

class AuthenticationManager {
    static let shared = AuthenticationManager()
    private let context = LAContext()
    private var hasAuthenticated = false
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(appDidBecomeActive),
                                             name: UIApplication.didBecomeActiveNotification,
                                             object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func requireAuthentication(on viewController: UIViewController, completion: @escaping () -> Void) {
        let savedPin = UserDefaults.standard.string(forKey: "userPin")
        let isBiometricsEnabled = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
        
        if savedPin != nil && !hasAuthenticated {
            let loginVC = FourDigitViewController()
            loginVC.modalPresentationStyle = .fullScreen
            viewController.present(loginVC, animated: false) {
                if isBiometricsEnabled {
                    self.authenticateWithBiometrics(on: loginVC, completion: completion)
                }
            }
        } else {
            completion() // No PIN set or already authenticated, proceed
        }
    }
    
    private func authenticateWithBiometrics(on viewController: UIViewController, completion: @escaping () -> Void) {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to access the app") { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if success {
                        
                        self.hasAuthenticated = true
                        viewController.dismiss(animated: false, completion: completion)
                    }
                }
            }
        }
    }
    
    @objc private func appDidBecomeActive() {
        
        hasAuthenticated = false // Reset authentication state
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            requireAuthentication(on: rootVC) {
                print("")
            }
        }
    }
}
