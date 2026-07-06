import UIKit


class forgetuserViewController: UIViewController, UITextFieldDelegate {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    // Properties
    var isChangingPassword = false
    private var oldPinVerified = false
    private let pinStackView = UIStackView()
    private var digitFields: [UITextField] = []
    private let submitButton = UIButton(type: .system)
    private var isConfirmingPin = false
    private var firstEnteredPin: String?
    private let messageLabel = UILabel()
    
    enum PinState {
        case setPin
        case confirmPin
        case login
        case verifyOldPin
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
        navigationItem.hidesBackButton = true
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        setupBackground()
        setupUI()
        
        if isChangingPassword && hasStoredPin() {
            currentState = .verifyOldPin
        } else if hasStoredPin() {
            currentState = .login
        } else {
            currentState = .setPin
            showPinRulesAlert()
        }
        updateUIForState()
        digitFields[0].becomeFirstResponder()
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
            let digitField = UITextField()
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
            
            let boxView = UIView()
            boxView.layer.borderColor = UIColor.white.cgColor
            boxView.layer.borderWidth = 3
            boxView.layer.cornerRadius = 8
            boxView.translatesAutoresizingMaskIntoConstraints = false
            
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
//            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
//            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
        if isChangingPassword {
            switch currentState {
            case .verifyOldPin:
                messageLabel.text = isArabicSelected ? "أدخل رمز PIN الحالي" : "Enter your current PIN"
                submitButton.setTitle(isArabicSelected ? "تأكيد" : "Verify", for: .normal)
            case .setPin:
                messageLabel.text = isArabicSelected ? "أدخل رمز PIN الجديد المكون من 4 أرقام" : "Please enter new 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "إرسال" : "Submit", for: .normal)
            case .confirmPin:
                messageLabel.text = isArabicSelected ? "تأكيد رمز PIN الجديد المكون من 4 أرقام" : "Confirm new 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "تأكيد" : "Confirm", for: .normal)
            case .login:
                messageLabel.text = isArabicSelected ? "أدخل رمز PIN لتسجيل الدخول" : "Enter your 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "تسجيل الدخول" : "Login", for: .normal)
            }
        } else if hasStoredPin() {
            messageLabel.text = isArabicSelected ? "أدخل رمز PIN لتسجيل الدخول" : "Enter 4-digit PIN"
            submitButton.setTitle(isArabicSelected ? "تسجيل الدخول" : "Login", for: .normal)
        } else {
            switch currentState {
            case .setPin:
                messageLabel.text = isArabicSelected ? "يرجى تعيين رمز PIN المكون من 4 أرقام" : "Please set your 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "إرسال" : "Submit", for: .normal)
            case .confirmPin:
                messageLabel.text = isArabicSelected ? "تأكيد رمز PIN المكون من 4 أرقام" : "Confirm your 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "تأكيد" : "Confirm", for: .normal)
            case .login:
                messageLabel.text = isArabicSelected ? "أدخل رمز PIN لتسجيل الدخول" : "Enter 4-digit PIN"
                submitButton.setTitle(isArabicSelected ? "تسجيل الدخول" : "Login", for: .normal)
            case .verifyOldPin:
                break
            }
        }
    }
    
    private func isValidPin(_ pin: String) -> (isValid: Bool, errorMessage: String?) {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            return (false, isArabicSelected ? "يجب أن يكون رمز PIN مكونًا من 4 أرقام تحتوي على أرقام فقط." : "PIN must be a 4-digit number with only numbers (0–9).")
        }
        
        if pin.allSatisfy({ $0 == pin.first }) {
            return (false, isArabicSelected ? "لا يمكن استخدام نفس الرقم لجميع المواضع (مثل 1111)." : "Cannot use the same digit for all positions (e.g., 1111).")
        }
        
        let digits = pin.map { Int(String($0))! }
        let isAscending = digits == (digits[0]...digits[0]+3).map { $0 % 10 }
        let isDescending = digits == (digits[0]-3...digits[0]).reversed().map { $0 >= 0 ? $0 : $0 + 10 }
        if isAscending || isDescending {
            return (false, isArabicSelected ? "تجنب الأرقام المتتالية (مثل 1234، 4321)." : "Avoid sequential digits (e.g., 1234, 4321).")
        }
        
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
        
        if isChangingPassword {
            switch currentState {
            case .verifyOldPin:
                do {
                    if try verifyPin(pin) {
                        oldPinVerified = true
                        currentState = .setPin
                        clearPinFields()
                        showPinRulesAlert()
                    } else {
                        messageLabel.text = isArabicSelected ? "رمز PIN غير صحيح. حاول مرة أخرى." : "Incorrect PIN. Try again."
                        clearPinFields()
                    }
                } catch {
                    messageLabel.text = isArabicSelected ? "فشل في التحقق من رمز PIN: \(error.localizedDescription)" : "Failed to verify PIN: \(error.localizedDescription)"
                    clearPinFields()
                }
                
            case .setPin:
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
                
            case .confirmPin:
                if pin == firstEnteredPin {
                    do {
                        try saveEncryptedPin(pin)
                        messageLabel.text = isArabicSelected ? "تم تغيير رمز PIN بنجاح" : "PIN changed successfully"
                        
                        let alert = UIAlertController(
                            title: isArabicSelected ? "تأكيد تغيير رمز PIN" : "PIN Change Confirmation",
                            message: isArabicSelected ? "تم تغيير رمز PIN الخاص بك بنجاح." : "Your PIN has been changed successfully.",
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                            guard let self = self else { return }
                            let newTokenVC = SettingsViewController()
                            self.navigationController?.pushViewController(newTokenVC, animated: true)
                        })
                        
                        present(alert, animated: true, completion: nil)
                    } catch FourDigitViewControllerEncryptionError.invalidPin(let message) {
                        messageLabel.text = isArabicSelected ? "رمز PIN غير صالح: \(message)" : "Invalid PIN: \(message)"
                        isConfirmingPin = false
                        firstEnteredPin = nil
                        currentState = .setPin
                        clearPinFields()
                        updateUIForState()
                    } catch {
                        messageLabel.text = isArabicSelected ? "فشل في حفظ رمز PIN: \(error.localizedDescription)" : "Failed to save PIN: \(error.localizedDescription)"
                        isConfirmingPin = false
                        firstEnteredPin = nil
                        currentState = .setPin
                        clearPinFields()
                        updateUIForState()
                    }
                } else {
                    messageLabel.text = isArabicSelected ? "رموز PIN غير متطابقة. حاول مرة أخرى." : "PINs do not match. Try again."
                    isConfirmingPin = false
                    firstEnteredPin = nil
                    currentState = .setPin
                    clearPinFields()
                    updateUIForState()
                }
                
            case .login:
                break
            }
        } else if !hasStoredPin() {
            let (isValid, errorMessage) = isValidPin(pin)
            if !isConfirmingPin {
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
                do {
                    try saveEncryptedPin(pin)
                    messageLabel.text = isArabicSelected ? "تم حفظ رمز PIN بنجاح" : "PIN saved successfully"
                    let newTokenVC = SettingsViewController()
                    navigationController?.pushViewController(newTokenVC, animated: true)
                } catch FourDigitViewControllerEncryptionError.invalidPin(let message) {
                    messageLabel.text = isArabicSelected ? "رمز PIN غير صالح: \(message)" : "Invalid PIN: \(message)"
                    isConfirmingPin = false
                    firstEnteredPin = nil
                    currentState = .setPin
                    clearPinFields()
                    updateUIForState()
                } catch {
                    messageLabel.text = isArabicSelected ? "فشل في حفظ رمز PIN: \(error.localizedDescription)" : "Failed to save PIN: \(error.localizedDescription)"
                    isConfirmingPin = false
                    firstEnteredPin = nil
                    currentState = .setPin
                    clearPinFields()
                    updateUIForState()
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
            do {
                if try verifyPin(pin) {
                    messageLabel.text = isArabicSelected ? "تم التحقق من رمز PIN بنجاح" : "PIN verified successfully"
                    let newTokenVC = SettingsViewController()
                    navigationController?.pushViewController(newTokenVC, animated: true)
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
        
        let encryptedData = try EncryptionHelper.shared.encrypt(pinData)
        let base64EncryptedString = encryptedData.base64EncodedString()
        UserDefaults.standard.set(base64EncryptedString, forKey: encryptedPinKey)
    }
    
    private func verifyPin(_ enteredPin: String) throws -> Bool {
        guard let base64String = UserDefaults.standard.string(forKey: encryptedPinKey),
              let encryptedData = base64String.fromBase64 else {
            return false
        }
        
        let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
        guard let decryptedPin = String(data: decryptedData, encoding: .utf8) else {
            return false
        }
        
        return decryptedPin == enteredPin
    }
    
    private func hasStoredPin() -> Bool {
        return UserDefaults.standard.string(forKey: encryptedPinKey) != nil
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
