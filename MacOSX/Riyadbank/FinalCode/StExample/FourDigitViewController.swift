import UIKit
import LocalAuthentication
import Security

// Custom error for FourDigitViewController
enum FourDigitViewControllerEncryptionError: Error {
    case encryptionFailed
    case invalidPin(String)
}

class FourDigitViewController: UIViewController, UITextFieldDelegate {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    private let pinStackView = UIStackView()
    private var digitFields: [UITextField] = []
    private let submitButton = UIButton(type: .system)
    private let languageButton = UIButton(type: .system)
    private var isConfirmingPin = false
    private var firstEnteredPin: String?
    private let messageLabel = UILabel()
    private let context = LAContext()
    private var digitField = UITextField()
    private var bottomBorder = UIView()
    
    private var isBiometricsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "isBiometricsEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "isBiometricsEnabled") }
    }
    
    enum PinState {
        case setPin
        case confirmPin
        case login
    }
    
    private var currentState: PinState = .setPin {
        didSet {
            updateUIForState()
        }
    }
    
    // UserDefaults key for encrypted PIN
    private let encryptedPinKey = "com.yourapp.encryptedPin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        setupBackground()
        if isJailbroken() {
            showJailbreakAlert()
            return
        }
        
        if isBypassToolDetected() {
            showJailbreakAlert()
            return
        }
        
        if isBiometricMethodTampered() {
            showJailbreakAlert()
            return
        }
        
        setupUI()
        
        if hasStoredPin() {
            currentState = .login
            checkBiometricAvailabilityAndAuthenticate()
            if !isBiometricsEnabled {
                digitFields[0].becomeFirstResponder()
            }
        } else {
            currentState = .setPin
            showPinRulesAlert()
        }
    }
    
    private func showJailbreakAlert() {
        let alert = UIAlertController(
            title: "Security Warning",
            message: "This app cannot run on a rooted device due to security restrictions.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
            exit(0)
        })
        present(alert, animated: true)
    }
    
    
    
    private func isBiometricMethodTampered() -> Bool {
        guard let method = class_getInstanceMethod(LAContext.self, #selector(LAContext.evaluatePolicy(_:localizedReason:reply:))) else {
            return true // method not found — something is wrong
        }
        let imp = method_getImplementation(method)
        let encoding = method_getTypeEncoding(method)
        // If either the implementation pointer or type encoding is nil, the method has likely been tampered with
        if encoding == nil || imp == nil {
            return true
        }
        return false
    }
    
    
    private func isBypassToolDetected() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            let suspiciousPaths = [
                "/usr/lib/libfrida-gadget.dylib",
                "/usr/lib/libcycript.dylib",
                "/Library/MobileSubstrate/DynamicLibraries/LibertyLite.dylib",
                "/Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.dylib",
                "/Library/Frameworks/CydiaSubstrate.framework",
                "/usr/lib/substrate/SubstrateLoader.dylib",
                "/usr/lib/substitute-inserter.dylib",
                "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib",
                "/Library/MobileSubstrate/DynamicLibraries/TweakInject.dylib",
                "/Library/MobileSubstrate/DynamicLibraries/Flex.dylib",
                "/usr/libexec/cydia/",
                "/var/lib/cydia"
            ]
        
            for path in suspiciousPaths {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
        
            let suspiciousLibraries = [
                "FridaGadget",
                "cycript",
                "LibertyLite",
                "SSLKillSwitch2",
                "SubstrateLoader",
                "substitute-inserter",
                "PreferenceLoader",
                "TweakInject",
                "Flex"
            ]
        
            for library in suspiciousLibraries {
                if dlopen(library, RTLD_NOW) != nil {
                    return true
                }
            }
        
            var flags: Int32 = 0
            var taskInfoCount = mach_msg_type_number_t(MemoryLayout<Int32>.size / MemoryLayout<UInt32>.size)
            let result = task_info(mach_task_self_, UInt32(TASK_DYLD_INFO), &flags, &taskInfoCount)
            if result == KERN_SUCCESS && (flags & 0x8000000) != 0 {
                return true
            }
        
            if isBiometricMethodTampered() {
                return true
            }
        
            return false
        #endif
    }
    
    
    
    
    private func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            let jailbreakPaths = [
                "/Applications/Cydia.app",
                "/Applications/Sileo.app",
                "/Library/MobileSubstrate/MobileSubstrate.dylib",
                "/bin/bash",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/private/var/lib/apt/",
                "/usr/bin/ssh",
                ]
//            ),
            for path in jailbreakPaths {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
    
            if let cydiaURL = URL(string: "cydia://package/com.example.package"), UIApplication.shared.canOpenURL(cydiaURL) {
                return true
            }
    
            let sandboxPath = "/private/var/mobile"
            do {
                let testString = "JailbreakTest" + UUID().uuidString
                let testFilePath = sandboxPath + "/\(testString).txt"
                try testString.write(toFile: testFilePath, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(atPath: testFilePath)
                return true // Successfully wrote outside sandbox → jailbroken
            } catch {
                return false // Write was blocked → not jailbroken
            }
        #endif
    }

    
    
    
    
    
    
    private func setupBackground() {
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
    }
    
    private func setupUI() {
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        pinStackView.axis = .horizontal
        pinStackView.spacing = 10
        pinStackView.distribution = .fillEqually
        pinStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinStackView)
        
        for i in 0..<4 {
            digitField = UITextField()
            digitField.textAlignment = .center
            digitField.keyboardType = .numberPad
            digitField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            digitField.borderStyle = .none
            digitField.textColor = .white
            digitField.isSecureTextEntry = true
            digitField.delegate = self
            digitField.tag = i
            digitField.translatesAutoresizingMaskIntoConstraints = false
            digitField.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            // Create a container view for the box
            let boxView = UIView()
            boxView.layer.borderColor = UIColor.white.cgColor
            boxView.layer.borderWidth = 3
            boxView.layer.cornerRadius = 8
            boxView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add text field to the box view
            boxView.addSubview(digitField)
            NSLayoutConstraint.activate([
                digitField.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
                digitField.centerYAnchor.constraint(equalTo: boxView.centerYAnchor),
                boxView.widthAnchor.constraint(equalToConstant: 48),
                boxView.heightAnchor.constraint(equalToConstant: 48)
            ])
            
            digitFields.append(digitField)
            pinStackView.addArrangedSubview(boxView)
        }
        
        submitButton.setTitle(isArabicSelected ? "إرسال" : "Submit", for: .normal)
        submitButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.titleLabel?.font = UIFont(name: "RBType-RB-Regular", size: 20)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont(name: "RBType-RB-Regular", size: 24)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 300),
            pinStackView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 10),
            pinStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            pinStackView.widthAnchor.constraint(equalToConstant: 200),
            submitButton.topAnchor.constraint(equalTo: pinStackView.bottomAnchor, constant: 30),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 150),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            messageLabel.bottomAnchor.constraint(equalTo: pinStackView.topAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func showPinRulesAlert() {
        let title = isArabicSelected ? "قواعد إنشاء رمز PIN" : "PIN Creation Rules"
        let message = isArabicSelected
            ? """
              يجب أن يكون رمز PIN الخاص بك مكونًا من 4 أرقام مع القواعد التالية:
              - استخدم الأرقام فقط (0–9).
              - لا تستخدم نفس الرقم لجميع المواضع الأربعة (مثل 1111).
              - تجنب الأرقام المتتالية (مثل 1234، 4321).
              - تجنب تكرار الأزواج (مثل 1122، 3344).
              اختر رمز PIN فريد ومتنوع لتحقيق أمان أفضل.
              """
            : """
              Your PIN must be a 4-digit number with the following rules:
              - Use only numbers (0–9).
              - Do not use the same digit for all 4 positions (e.g., 1111).
              - Avoid sequential digits (e.g., 1234, 4321).
              - Avoid repeating pairs (e.g., 1122, 3344).
              Choose a unique and varied PIN for better security.
              """
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        // Create a UITextView for the message with dynamic alignment
        let messageTextView = UITextView()
        messageTextView.text = message
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.textAlignment = isArabicSelected ? .right : .left
        messageTextView.font = UIFont(name: "RBType-RB-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        if #available(iOS 13.0, *) {
                messageTextView.textColor = .label // Dynamic color for iOS 13.0+
            } else {
                messageTextView.textColor = .black // Fallback for iOS < 13.0
            }
        messageTextView.backgroundColor = .clear
        messageTextView.textContainer.lineBreakMode = isArabicSelected ? .byCharWrapping : .byWordWrapping
        messageTextView.textContainerInset = .zero
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a container view for the text view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageTextView)
        
        // Add constraints for the text view within the container
        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            messageTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            messageTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            messageTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            messageTextView.widthAnchor.constraint(lessThanOrEqualToConstant: 260)
        ])
        
        // Add the container view to the alert
        alert.view.addSubview(containerView)
        
        // Constrain the container view within the alert
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60),
            containerView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: alert.view.bottomAnchor, constant: -60)
        ])
        
        // Set preferred content size to ensure sufficient space
        alert.preferredContentSize = CGSize(width: 320, height: 350)
        
        // Add OK action
        alert.addAction(UIAlertAction(title: isArabicSelected ? "موافق" : "OK", style: .default) { [weak self] _ in
            self?.updateUIForState()
            self?.digitFields[0].becomeFirstResponder()
        })
        
        present(alert, animated: true)
    }
    
    private func updateUIForState() {
        messageLabel.isHidden = false
        submitButton.isHidden = false
        for digitField in digitFields {
            digitField.isHidden = false
            digitField.superview?.isHidden = false
            if let bottomBorder = digitField.subviews.first {
                bottomBorder.isHidden = false
            }
        }
        
        if hasStoredPin() {
            messageLabel.text = isArabicSelected ? "الرجاء إدخال الرمز السري الخاص بك" : "Enter 4-digit PIN"
            submitButton.setTitle(isArabicSelected ? "يؤكد" : "VERIFY", for: .normal)
        } else {
            switch currentState {
            case .setPin:
                messageLabel.text = isArabicSelected ? "يرجى تعيين رمز PIN المكون من 4 أرقام" : "Please set your 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "إرسال" : "Submit", for: .normal)
            case .confirmPin:
                messageLabel.text = isArabicSelected ? "قم بتأكيد رمز PIN المكون من 4 أرقام" : "Confirm your 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "تأكيد" : "Confirm", for: .normal)
            case .login:
                messageLabel.text = isArabicSelected ? "أدخل الرمز السري للدخول" : "Enter 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "يؤكد" : "VERIFY", for: .normal)
            }
        }
    }
    
    private func isValidPin(_ pin: String) -> (isValid: Bool, errorMessage: String?) {
        // Check if PIN is 4 digits and contains only numbers
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            return (false, isArabicSelected ? "يجب أن يكون رمز PIN مكونًا من 4 أرقام تحتوي على أرقام فقط." : "PIN must be a 4-digit number with only numbers (0–9).")
        }
        
        // Check for same digit in all positions (e.g., 1111)
        if pin.allSatisfy({ $0 == pin.first }) {
            return (false, isArabicSelected ? "لا يمكن استخدام نفس الرقم لجميع المواضع (مثل 1111)." : "Cannot use the same digit for all positions (e.g., 1111).")
        }
        
        // Check for sequential digits (e.g., 1234, 4321)
        let digits = pin.map { Int(String($0))! }
        let isAscending = digits == (digits[0]...digits[0]+3).map { $0 % 10 }
        let isDescending = digits == (digits[0]-3...digits[0]).reversed().map { $0 >= 0 ? $0 : $0 + 10 }
        if isAscending || isDescending {
            return (false, isArabicSelected ? "تجنب الأرقام المتتالية (مثل 1234، 4321)." : "Avoid sequential digits (e.g., 1234, 4321).")
        }
        
        // Check for repeating pairs (e.g., 1122, 3344)
        if pin[pin.startIndex] == pin[pin.index(pin.startIndex, offsetBy: 1)] &&
           pin[pin.index(pin.startIndex, offsetBy: 2)] == pin[pin.index(pin.startIndex, offsetBy: 3)] {
            return (false, isArabicSelected ? "تجنب تكرار الأزواج (مثل 1122، 3344)." : "Avoid repeating pairs (e.g., 1122, 3344).")
        }
        
        return (true, nil)
    }
    
    @objc private func submitButtonTapped() {
        let pin = digitFields.compactMap { $0.text }.joined()
        
        if pin.count != 4 {
            messageLabel.text = isArabicSelected ? "يرجى إدخال رمز PIN مكون من 4 أرقام" : "Please enter a 4-digit PIN"
            return
        }
        
        if !hasStoredPin() {
            if !isConfirmingPin {
                let (isValid, errorMessage) = isValidPin(pin)
                if !isValid {
                    messageLabel.text = errorMessage
                    clearPinFields()
                    return
                }
                firstEnteredPin = pin
                isConfirmingPin = true
                currentState = .confirmPin
                clearPinFields()
                updateUIForState()
            } else if pin == firstEnteredPin {
                // Encrypt and save the PIN
                do {
                    try saveEncryptedPin(pin)
                    messageLabel.text = isArabicSelected ? "تم حفظ رمز PIN بنجاح" : "PIN saved successfully"
                    
                    var error: NSError?
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        let alert = UIAlertController(
                            title: isArabicSelected ? "تمكين المصادقة البيومترية" : "Enable Biometrics",
                            message: isArabicSelected ? "هل ترغب في تمكين المصادقة البيومترية؟" : "Would you like to enable biometric authentication?",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                            self?.isBiometricsEnabled = true
                            self?.transitionToMainTabBar()
                        })
                        alert.addAction(UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
                            self?.transitionToMainTabBar()
                        })
                        present(alert, animated: true)
                    } else {
                        transitionToMainTabBar()
                    }
                } catch FourDigitViewControllerEncryptionError.invalidPin(let message) {
                    messageLabel.text = isArabicSelected ? "رمز PIN غير صالح: \(message)" : "Invalid PIN: \(message)"
                    clearPinFields()
                } catch {
                    messageLabel.text = isArabicSelected ? "فشل في حفظ رمز PIN: \(error.localizedDescription)" : "Failed to save PIN: \(error.localizedDescription)"
                    clearPinFields()
                }
            } else {
                messageLabel.text = isArabicSelected ? "رموز PIN غير متطابقة. حاول مرة أخرى." : "PINs do not match. Try again."
                isConfirmingPin = false
                firstEnteredPin = nil
                currentState = .setPin
                clearPinFields()
                updateUIForState()
            }
        } else {
            // Verify the PIN
            do {
                if try verifyPin(pin) {
                    messageLabel.text = isArabicSelected ? "تم التحقق من رمز PIN بنجاح" : "PIN verified successfully"
                    transitionToMainTabBar()
                } else {
                    messageLabel.text = isArabicSelected ? "رمز PIN غير صحيح. حاول مرة أخرى." : "Incorrect PIN. Try again."
                    clearPinFields()
                }
            } catch {
                messageLabel.text = isArabicSelected ? "فشل في التحقق من رمز PIN: \(error.localizedDescription)" : "Failed to verify PIN: \(error.localizedDescription)"
                clearPinFields()
            }
        }
    }
    
    // MARK: - Encryption and Storage Methods
    
    private func saveEncryptedPin(_ pin: String) throws {
        let (isValid, errorMessage) = isValidPin(pin)
        guard isValid else {
            throw FourDigitViewControllerEncryptionError.invalidPin(errorMessage ?? "Invalid PIN")
        }
        
        guard let pinData = pin.data(using: .utf8) else {
            throw FourDigitViewControllerEncryptionError.encryptionFailed
        }
        
        // Encrypt the PIN using EncryptionHelper
        let encryptedData = try EncryptionHelper.shared.encrypt(pinData)
        
        // Convert to Base64 for UserDefaults storage
        let base64EncryptedString = encryptedData.base64EncodedString()
        
        // Save encrypted PIN to UserDefaults
        UserDefaults.standard.set(base64EncryptedString, forKey: encryptedPinKey)
    }
    
    private func verifyPin(_ enteredPin: String) throws -> Bool {
        guard let base64String = UserDefaults.standard.string(forKey: encryptedPinKey),
              let encryptedData = Data(base64Encoded: base64String) else {
            return false
        }
        
        // Decrypt the PIN
        let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
        guard let decryptedPin = String(data: decryptedData, encoding: .utf8) else {
            return false
        }
        
        return decryptedPin == enteredPin
    }
    
    private func hasStoredPin() -> Bool {
        return UserDefaults.standard.string(forKey: encryptedPinKey) != nil
    }
    
    private func transitionToMainTabBar() {
        if let window = UIApplication.shared.windows.first {
            let tabBarVC = MainTabBarController()
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
        }
    }
    
    private func checkBiometricAvailabilityAndAuthenticate() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if isBiometricsEnabled {
                let biometricType = context.biometryType
                let supportsFaceID = biometricType == .faceID
                let supportsTouchID = biometricType == .touchID
                
                if supportsFaceID || supportsTouchID {
                    showBiometricOptions(supportsFaceID: supportsFaceID, supportsTouchID: supportsTouchID)
                } else {
                    updateUIForState()
                    digitFields[0].becomeFirstResponder()
                }
            } else {
                updateUIForState()
                digitFields[0].becomeFirstResponder()
            }
        } else {
            isBiometricsEnabled = false
            updateUIForState()
            digitFields[0].becomeFirstResponder()
            if let error = error {
                handleBiometricError(error)
            }
        }
    }
    
    private func showBiometricOptions(supportsFaceID: Bool, supportsTouchID: Bool) {
        messageLabel.isHidden = true
        submitButton.isHidden = true
        for digitField in digitFields {
            digitField.isHidden = true
            digitField.textColor = .white
            digitField.tintColor = .white
            digitField.superview?.isHidden = true
            if let bottomBorder = digitField.subviews.first {
                bottomBorder.isHidden = false
            }
        }
        
        let alert = UIAlertController(
            title: isArabicSelected ? "خيارات تسجيل الدخول" : "Login Options",
            message: isArabicSelected ? "اختر الطريقة التي ترغب في استخدامها للمصادقة:" : "Choose how you'd like to authenticate:",
            preferredStyle: .actionSheet
        )
        
        if supportsFaceID {
            alert.addAction(UIAlertAction(title: isArabicSelected ? "استخدم Face ID" : "Use Face ID", style: .default) { [weak self] _ in
                self?.authenticateWithBiometrics(biometricType: .faceID)
            })
        }
        
        if supportsTouchID {
            alert.addAction(UIAlertAction(title: isArabicSelected ? "استخدم Touch ID" : "Use Touch ID", style: .default) { [weak self] _ in
                self?.authenticateWithBiometrics(biometricType: .touchID)
            })
        }
        
        alert.addAction(UIAlertAction(title: isArabicSelected ? "استخدم الرقم السري" : "Use PIN", style: .default) { [weak self] _ in
            self?.updateUIForState()
            self?.digitFields[0].becomeFirstResponder()
        })
        
        alert.addAction(UIAlertAction(title: isArabicSelected ? "إلغاء" : "Cancel", style: .cancel, handler: nil))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(
                x: view.bounds.midX,
                y: view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func authenticateWithBiometrics(biometricType: LABiometryType? = nil) {
        let reason = biometricType == .faceID
            ? (isArabicSelected ? "المصادقة باستخدام Face ID" : "Authenticate with Face ID")
            : (isArabicSelected ? "المصادقة باستخدام Touch ID" : "Authenticate with Touch ID")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.transitionToMainTabBar()
                } else {
                    self.updateUIForState()
                    self.digitFields[0].becomeFirstResponder()
                    if let error = error {
                        self.handleBiometricError(error as NSError)
                    }
                }
            }
        }
    }
    
    private func handleBiometricError(_ error: NSError) {
        let context = LAContext()
        
        var errorPointer: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorPointer) else {
            return
        }
        
        let biometricType = context.biometryType
        let biometricName = biometricType == .faceID
            ? (isArabicSelected ? "تعرف الوجه" : "Face ID")
            : (isArabicSelected ? "التعرف على بصمة الإصبع" : "Touch ID")
        
        let message: String
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            message = isArabicSelected
                ? "\(biometricName) غير متاح"
                : "\(biometricName) is not available"
        case LAError.biometryNotEnrolled.rawValue:
            message = isArabicSelected
                ? "لا توجد بيانات \(biometricName) مسجلة"
                : "No \(biometricName) data enrolled"
        case LAError.biometryLockout.rawValue:
            message = isArabicSelected
                ? "\(biometricName) مقفلة، يرجى استخدام الرقم السري"
                : "\(biometricName) locked out, please use PIN"
        case LAError.userCancel.rawValue:
            message = isArabicSelected
                ? "تم إلغاء المصادقة"
                : "Authentication cancelled"
        default:
            message = isArabicSelected
                ? "\(biometricName) خطأ في المصادقة"
                : "\(biometricName) authentication error"
        }
        
        showAlert(title: "Authentication Error", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func clearPinFields() {
        for field in digitFields {
            field.text = ""
        }
        digitFields[0].becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        if string.isEmpty {
            textField.text = ""
            if textField.tag > 0 {
                digitFields[textField.tag - 1].becomeFirstResponder()
            }
            return false
        }
        
        if text.isEmpty, string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            textField.text = string
            if textField.tag < 3 {
                digitFields[textField.tag + 1].becomeFirstResponder()
            }
            return false
        }
        return false
    }
}
