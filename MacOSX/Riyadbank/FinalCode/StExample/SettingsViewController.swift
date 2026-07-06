import UIKit
import LocalAuthentication
import EntrustIGMobile

class SettingsViewController: UIViewController {
    private let context = LAContext()
    private var identity: ETIdentity?
    private var isBiometricsEnabled = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
    private var biometricButton: UIButton!
    private var biometricSwitch: UISwitch!
    private var arabicButton: UIButton!
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        isBiometricsEnabled = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
        
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        
        navigationItem.hidesBackButton = true
        setupSettingsOptions()
    }
    
    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    private func setupSettingsOptions() {
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 10
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackgroundView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.addSubview(stackView)

        let settingsLabel = UILabel()
        settingsLabel.text = isArabicSelected ? "الإعدادات" : "SETTINGS"
        settingsLabel.textColor = .black
        
        settingsLabel.font = UIFont(name: "RBType-RB-Medium", size: 20)
        settingsLabel.textAlignment = isArabicSelected ? .right : .left

        let changePinButton = UIButton(type: .system)
        if let customFont = UIFont(name: "RBType-RB-Medium", size: 18) {
            changePinButton.titleLabel?.font = customFont
        } else {
            print("RBType-RB-Medium font not found!")
            changePinButton.titleLabel?.font = UIFont.systemFont(ofSize: 18) // fallback
        }
        
        changePinButton.setTitle(isArabicSelected ? "تغير الرمز السري" : "Change PIN", for: .normal)
        changePinButton.setTitleColor(.white, for: .normal)
        changePinButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        changePinButton.layer.cornerRadius = 5
//        changePinButton.titleLabel?.font = UIFont(name: "GeezaPro", size: 18)
        changePinButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        changePinButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: isArabicSelected ? 0 : 20, bottom: 0, right: isArabicSelected ? 20 : 0)
        changePinButton.translatesAutoresizingMaskIntoConstraints = false
        changePinButton.addTarget(self, action: #selector(forgetpassword), for: .touchUpInside)

        let chevronLabel = UILabel()
        chevronLabel.text = "▶"
        chevronLabel.textColor = .white
        chevronLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        chevronLabel.translatesAutoresizingMaskIntoConstraints = false
        changePinButton.addSubview(chevronLabel)

        biometricButton = UIButton(type: .system)
        biometricButton.setTitle(isArabicSelected ? "تفعيل البصمة" : "Enable Biometrics", for: .normal)
        biometricButton.setTitleColor(.white, for: .normal)
        biometricButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        biometricButton.layer.cornerRadius = 5
        biometricButton.titleLabel?.font = UIFont(name: "RBType-RB-Medium", size: 18)
        biometricButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        biometricButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: isArabicSelected ? 0 : 20, bottom: 0, right: isArabicSelected ? 20 : 0)
        biometricButton.translatesAutoresizingMaskIntoConstraints = false

        biometricSwitch = UISwitch()
        biometricSwitch.backgroundColor = .white
        biometricSwitch.layer.cornerRadius = biometricSwitch.frame.height / 2
        biometricSwitch.thumbTintColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        biometricSwitch.onTintColor = .white
        biometricSwitch.tintColor = .white
        biometricSwitch.isOn = isBiometricsEnabled
        biometricSwitch.translatesAutoresizingMaskIntoConstraints = false
        biometricSwitch.addTarget(self, action: #selector(toggleBiometrics), for: .valueChanged)
        biometricButton.addSubview(biometricSwitch)

        arabicButton = UIButton(type: .system)
        setupArabicButton()
        let arabicchevronLabel = UILabel()
        arabicchevronLabel.text = "▶"
        arabicchevronLabel.textColor = .white
        arabicchevronLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        arabicchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        arabicButton.addSubview(arabicchevronLabel)

        let setNewSoftTokenButton = UIButton(type: .system)
        setNewSoftTokenButton.setTitle(isArabicSelected ? "تسجيل رمز تفعيل جديد" : "Set New Soft Token", for: .normal)
        setNewSoftTokenButton.setTitleColor(.white, for: .normal)
        setNewSoftTokenButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        setNewSoftTokenButton.layer.cornerRadius = 5
        setNewSoftTokenButton.titleLabel?.font = UIFont(name: "RBType-RB-Medium", size: 18)
        setNewSoftTokenButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        setNewSoftTokenButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: isArabicSelected ? 0 : 20, bottom: 0, right: isArabicSelected ? 20 : 0)
        setNewSoftTokenButton.translatesAutoresizingMaskIntoConstraints = false
        setNewSoftTokenButton.addTarget(self, action: #selector(addTokenButtonTapped), for: .touchUpInside)

        let setNewSoftTokenButtonchevronLabel = UILabel()
        setNewSoftTokenButtonchevronLabel.text = "▶"
        setNewSoftTokenButtonchevronLabel.textColor = .white
        setNewSoftTokenButtonchevronLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        setNewSoftTokenButtonchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        setNewSoftTokenButton.addSubview(setNewSoftTokenButtonchevronLabel)
        
        let registertoken = UILabel()
        registertoken.text = isArabicSelected ? "رموز التفعيل المسجلة" : "Registered Tokens"
        registertoken.textColor = .black
        registertoken.font = UIFont(name: "RBType-RB-Bold", size: 18)
        registertoken.textAlignment = isArabicSelected ? .right : .left
        
        stackView.addArrangedSubview(changePinButton)
        stackView.addArrangedSubview(biometricButton)
        stackView.addArrangedSubview(arabicButton)
        stackView.addArrangedSubview(registertoken)
        stackView.addArrangedSubview(setNewSoftTokenButton)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.tag = 2
        scrollView.showsVerticalScrollIndicator = true
        whiteBackgroundView.addSubview(scrollView)

        let tokenStackView = UIStackView()
        tokenStackView.axis = .vertical
        tokenStackView.spacing = 10
        tokenStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tokenStackView)

        let defaults = UserDefaults.standard
        var savedTokens: [[String: String]] = []

        if let encryptedData = defaults.object(forKey: "savedTokens") as? Data {
            do {
                let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
                if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                    print("")
                }
                savedTokens = try JSONSerialization.jsonObject(with: decryptedData, options: []) as? [[String: String]] ?? []
            } catch {
                print("")
            }
        } else {
            savedTokens = defaults.array(forKey: "savedTokens") as? [[String: String]] ?? []
        }

        

        if savedTokens.isEmpty {
            let noTokenLabel = UILabel()
            noTokenLabel.text = isArabicSelected ? "لم يتم العثور على رموز محفوظة" : "No saved tokens found"
            noTokenLabel.textAlignment = .center
            noTokenLabel.textColor = .gray
            noTokenLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16, weight: .bold)
            noTokenLabel.translatesAutoresizingMaskIntoConstraints = false
            tokenStackView.addArrangedSubview(noTokenLabel)
            
            NSLayoutConstraint.activate([
                noTokenLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            for token in savedTokens {
                if let tokenName = token["tokenName"] {
                    let tokenButton = UIButton(type: .system)
                    tokenButton.setTitle(tokenName, for: .normal)
                    tokenButton.setTitleColor(.white, for: .normal)
                    tokenButton.backgroundColor = UIColor(
                        red: 0/255,
                        green: 175/255,
                        blue: 154/255,
                        alpha: 1.0
                    )
                    tokenButton.layer.cornerRadius = 5
                    tokenButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 18)
                    tokenButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
                    tokenButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: isArabicSelected ? 0 : 20, bottom: 0, right: isArabicSelected ? 20 : 0)
                    tokenButton.translatesAutoresizingMaskIntoConstraints = false
                    tokenButton.addTarget(self, action: #selector(tokenButtonTapped(_:)), for: .touchUpInside)
                    
                    let chevronLabel = UILabel()
                    chevronLabel.text = "▶"
                    chevronLabel.textColor = .white
                    chevronLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                    chevronLabel.translatesAutoresizingMaskIntoConstraints = false
                    tokenButton.addSubview(chevronLabel)
                    
                    tokenStackView.addArrangedSubview(tokenButton)
                    
                    NSLayoutConstraint.activate([
                        tokenButton.heightAnchor.constraint(equalToConstant: 40),
                        chevronLabel.centerYAnchor.constraint(equalTo: tokenButton.centerYAnchor),
                        chevronLabel.trailingAnchor.constraint(equalTo: tokenButton.trailingAnchor, constant: -15)
                    ])
                }
            }
        }

        NSLayoutConstraint.activate([
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 150),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 10),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 2), // Increased spacing
            scrollView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            tokenStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            tokenStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tokenStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tokenStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            tokenStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            changePinButton.heightAnchor.constraint(equalToConstant: 40),
            chevronLabel.centerYAnchor.constraint(equalTo: changePinButton.centerYAnchor),
            chevronLabel.trailingAnchor.constraint(equalTo: changePinButton.trailingAnchor, constant: -15),
            
            biometricButton.heightAnchor.constraint(equalToConstant: 40),
            biometricSwitch.centerYAnchor.constraint(equalTo: biometricButton.centerYAnchor),
            biometricSwitch.trailingAnchor.constraint(equalTo: biometricButton.trailingAnchor, constant: -15),
            
            arabicButton.heightAnchor.constraint(equalToConstant: 40),
            arabicchevronLabel.centerYAnchor.constraint(equalTo: arabicButton.centerYAnchor),
            arabicchevronLabel.trailingAnchor.constraint(equalTo: arabicButton.trailingAnchor, constant: -15),
            
            setNewSoftTokenButton.heightAnchor.constraint(equalToConstant: 40),
            setNewSoftTokenButtonchevronLabel.centerYAnchor.constraint(equalTo: setNewSoftTokenButton.centerYAnchor),
            setNewSoftTokenButtonchevronLabel.trailingAnchor.constraint(equalTo: setNewSoftTokenButton.trailingAnchor, constant: -15)
        ])

        updateBiometricButtonTitle()
    }
    
    private func setupArabicButton() {
        let isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        arabicButton.setTitleColor(.white, for: .normal)
        arabicButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        arabicButton.layer.cornerRadius = 5
        arabicButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 18)
        
        if isArabicSelected {
            let title = "English"
            arabicButton.setTitle(title, for: .normal)
            arabicButton.contentHorizontalAlignment = .right
            arabicButton.titleLabel?.textAlignment = .right
            arabicButton.semanticContentAttribute = .forceRightToLeft
            arabicButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        } else {
            let title = " العربية "
            arabicButton.setTitle(title, for: .normal)
            arabicButton.contentHorizontalAlignment = .left
            arabicButton.titleLabel?.textAlignment = .left
            arabicButton.semanticContentAttribute = .forceLeftToRight
            arabicButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        
        arabicButton.translatesAutoresizingMaskIntoConstraints = false
        arabicButton.addTarget(self, action: #selector(arabiclanguagechange(_:)), for: .touchUpInside)
    }
    
    private func updateBiometricButtonTitle() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let biometricType = context.biometryType
            let biometricName = biometricType == .faceID ? "Face ID" : "Touch ID"
            biometricButton.setTitle(
                isArabicSelected ? "تفعيل \(biometricName)" : "Activate \(biometricName)",
                for: .normal
            )
        } else {
            biometricButton.setTitle(
                isArabicSelected ? "تفعيل البصمة" : "Biometric",
                for: .normal
            )
        }
    }
    
    @objc private func addTokenButtonTapped() {
        let newTokenVC = NewSoftTokenViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
    
    @objc func arabiclanguagechange(_ sender: UIButton) {
        let isCurrentlyArabic = UserDefaults.standard.bool(forKey: "isArabicSelected")
        let alert = UIAlertController(
            title: isArabicSelected ? "تغيير اللغة" : "Change Language",
            message: nil,
            preferredStyle: .alert
        )
        
        if isCurrentlyArabic {
            alert.message = isArabicSelected ? "هل تريد التبديل إلى الإنجليزية؟" : "Do you want to switch to English?"
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                UserDefaults.standard.set(false, forKey: "isArabicSelected")
                self.setupArabicButton()
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                self.restartAppWithNewLanguage()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
        } else {
            alert.message = "Do you want to switch to Arabic?"
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                UserDefaults.standard.set(true, forKey: "isArabicSelected")
                self.setupArabicButton()
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                self.restartAppWithNewLanguage()
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func restartAppWithNewLanguage() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let tabBarController = MainTabBarController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
    }
    
    @objc private func forgetpassword() {
        let alert = UIAlertController(
            title: isArabicSelected ? "تغيير كلمة المرور" : "Change Password",
            message: isArabicSelected ? "هل تريد تغيير كلمة المرور الخاصة بك؟" : "Do you want to change your password?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let newTokenVC = forgetuserViewController()
            newTokenVC.isChangingPassword = true
            self.navigationController?.pushViewController(newTokenVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func tokenButtonTapped(_ sender: UIButton) {
        guard let selectedTokenName = sender.titleLabel?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !selectedTokenName.isEmpty else {
            
            return
        }
        let defaults = UserDefaults.standard
        var savedTokens: [[String: String]] = []

        if let encryptedData = defaults.object(forKey: "savedTokens") as? Data {
            do {
                let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
                if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                    print("")
                }
                savedTokens = try JSONSerialization.jsonObject(with: decryptedData, options: []) as? [[String: String]] ?? []
            } catch {
                print("")
            }
        } else {
            savedTokens = defaults.array(forKey: "savedTokens") as? [[String: String]] ?? []
        }

        if let token = savedTokens.first(where: { $0["tokenName"] == selectedTokenName }) {
            guard let serialNumber = token["serialNumber"],
                  let activationCode = token["activationCode"] else {
                
                return
            }
            

            let savedOTP = defaults.string(forKey: "savedIdentity_\(serialNumber)") ?? ""

            if let savedData = defaults.data(forKey: "savedIdentity_\(serialNumber)") {
                do {
                    identity = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? ETIdentity
                } catch {
                    print("")
                }
            }
            
            loadSavedData1(tokenName: selectedTokenName, serialNumber: serialNumber, activationCode: activationCode, savedOTP: savedOTP)
        }
    }
    
    private func loadSavedData1(tokenName: String, serialNumber: String, activationCode: String, savedOTP: String) {
        let tokenListVC = TokenDeleteRecord(
            tokenName: tokenName,
            serialNumber: serialNumber,
            activationCode: activationCode,
            savedOTP: savedOTP
        )
        
        navigationController?.pushViewController(tokenListVC, animated: true)
    }
    
    @objc private func toggleBiometrics() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let biometricType = context.biometryType
            let biometricName = biometricType == .faceID ? "Face ID" : "Touch ID"
            
            biometricButton.setTitle("Activate \(biometricName)", for: .normal)
            
            if isBiometricsEnabled {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "Authenticate with \(biometricName) to disable it") { success, authenticationError in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        if success {
                            let confirmationAlert = UIAlertController(
                                title: self.isArabicSelected ? "تعطيل \(biometricName)" : "Disable \(biometricName)",
                                message: self.isArabicSelected ? "هل أنت متأكد أنك تريد تعطيل مصادقة \(biometricName)؟" : "Are you sure you want to disable \(biometricName) authentication?",
                                preferredStyle: .alert
                            )
                            confirmationAlert.addAction(UIAlertAction(
                                title: "OK",
                                style: .default) { _ in
                                    DispatchQueue.main.async {
                                        UserDefaults.standard.set(false, forKey: "isBiometricsEnabled")
                                        self.isBiometricsEnabled = false
                                        self.biometricSwitch.isOn = false
                                        
                                        self.showAlert(
                                            title: self.isArabicSelected ? "نجاح" : "Success",
                                            message: self.isArabicSelected ? "تم تعطيل \(biometricName)" : "\(biometricName) has been disabled"
                                        )
                                    }
                            })
                            
                            confirmationAlert.addAction(UIAlertAction(
                                title: "Cancel",
                                style: .cancel) { _ in
                                    self.biometricSwitch.isOn = true
                            })
                            
                            self.present(confirmationAlert, animated: true)
                        } else {
                            let errorMessage = self.isArabicSelected
                                ? "فشل التحقق. لا يمكن تعطيل \(biometricName)."
                                : "Authentication failed. Cannot disable \(biometricName)."
                            self.showAlert(title: self.isArabicSelected ? "خطأ" : "Error", message: errorMessage)
                        }
                    }
                }
            } else {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "Enable \(biometricName) authentication") { success, authenticationError in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if success {
                            UserDefaults.standard.set(true, forKey: "isBiometricsEnabled")
                            self.isBiometricsEnabled = true
                            self.biometricSwitch.isOn = true
                            
                            let successMessage = self.isArabicSelected
                                ? "\(biometricName) تم التمكين بنجاح"
                                : "\(biometricName) enabled successfully"
                            self.showAlert(title: self.isArabicSelected ? "نجاح" : "Success", message: successMessage)
                        } else {
                            let errorMessage = self.isArabicSelected
                                ? "فشل التحقق من \(biometricName)"
                                : "\(biometricName) authentication failed"
                            self.showAlert(title: self.isArabicSelected ? "خطأ" : "Error", message: errorMessage)
                            self.biometricSwitch.isOn = false
                        }
                    }
                }
            }
        } else {
            isBiometricsEnabled = false
            UserDefaults.standard.set(false, forKey: "isBiometricsEnabled")
            biometricSwitch.isOn = false
            biometricButton.setTitle("Activate Biometrics", for: .normal)
            
            if let error = error {
                handleBiometricError(error)
            }
            let alertTitle = self.isArabicSelected ? "غير متوفر" : "Unavailable"
            let alertMessage = self.isArabicSelected
                ? "المصادقة البيومترية غير متاحة على هذا الجهاز"
                : "Biometric authentication is not available on this device"
            self.showAlert(title: alertTitle, message: alertMessage)
        }
    }
    
    private func handleBiometricError(_ error: NSError) {
        let biometricType = context.biometryType
        let biometricName = biometricType == .faceID ? "Face ID" : "Touch ID"
        
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            print("")
        case LAError.biometryNotEnrolled.rawValue:
            let alertTitle = self.isArabicSelected ? "خطأ" : "Error"
            let alertMessage = self.isArabicSelected
                ? "يرجى إعداد \(biometricName) في إعدادات جهازك"
                : "Please set up \(biometricName) in your device settings"
            self.showAlert(title: alertTitle, message: alertMessage)
        case LAError.biometryLockout.rawValue:
            let alertTitle = self.isArabicSelected ? "مقفل" : "Locked"
            let alertMessage = self.isArabicSelected
                ? "\(biometricName) مقفل. يرجى إلغاء قفله في الإعدادات"
                : "\(biometricName) is locked. Please unlock it in settings"
            self.showAlert(title: alertTitle, message: alertMessage)
        default:
            print("")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

