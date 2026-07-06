import UIKit
import EntrustIGMobile

class TokenListViewController: UIViewController {
    
    // Properties to store passed data
    var tokenName: String?
    var serialNumber: String?
    var activationCode: String?
    var savedOTP: String?
    private var lastOtpUpdate: Date?
    private var identity: ETIdentity?
    private var otpLabel: UILabel?
    private var otpCountdown: UIProgressView?
    private var countdownTimer: Timer?
    private var nameLabel: UILabel?
    private var startLabel: UILabel?
    private var expirationLabel: UILabel?
    private var endLabel: UILabel?
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    // Custom initializer
    init(tokenName: String?, serialNumber: String?, activationCode: String?, savedOTP: String?) {
        self.tokenName = tokenName
        self.serialNumber = serialNumber
        self.activationCode = activationCode
        self.savedOTP = savedOTP
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        navigationItem.hidesBackButton = true
        
        // Set background color
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        
        // Create bank image view
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        // Create white background view
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 15
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackgroundView)
        
        // Create and configure tokenLabel (Security Code)
        let tokenLabel = UILabel()
        tokenLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenLabel.text = isArabicSelected ? "رمز التفعيل" : "Security Code"
        tokenLabel.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
        tokenLabel.textAlignment = .center
        tokenLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30) : UIFont.systemFont(ofSize: 30)
        whiteBackgroundView.addSubview(tokenLabel)
        
        // Create stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.addSubview(stackView)
        
        // Initialize and configure nameLabel (Token name)
//        nameLabel = UILabel()
//        nameLabel?.textAlignment = .center
//        nameLabel?.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
//        nameLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        nameLabel?.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel?.text = tokenName ?? "Unknown Token"
        
        // Initialize and configure otpLabel (Security code)
        otpLabel = UILabel()
        otpLabel?.textAlignment = .center
        otpLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        otpLabel?.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
        otpLabel?.isHidden = false
        otpLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        otpLabel?.text = savedOTP ?? "000-000"
        
        // Initialize and configure otpCountdown
        otpCountdown = UIProgressView(progressViewStyle: .default)
        otpCountdown?.progressTintColor = UIColor(red: 243/255, green: 202/255, blue: 64/255, alpha: 1.0)
        otpCountdown?.trackTintColor = .black
        otpCountdown?.progress = 1.0
        otpCountdown?.isHidden = false
        otpCountdown?.translatesAutoresizingMaskIntoConstraints = false
        
        // Initialize countdown labels
        startLabel = UILabel()
        startLabel?.translatesAutoresizingMaskIntoConstraints = false
        startLabel?.text = "0"
        startLabel?.textColor = .black
        startLabel?.font = UIFont.systemFont(ofSize: 14)
        
        expirationLabel = UILabel()
        expirationLabel?.translatesAutoresizingMaskIntoConstraints = false
        expirationLabel?.text = isArabicSelected ? "مدةالصلاحية" : "Expiration Time"
        expirationLabel?.textColor = .black
        expirationLabel?.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        expirationLabel?.textAlignment = .center
        
        endLabel = UILabel()
        endLabel?.translatesAutoresizingMaskIntoConstraints = false
        endLabel?.text = "30"
        endLabel?.textColor = .black
        endLabel?.font = UIFont.systemFont(ofSize: 14)
        
        // Create countdown container
        let countdownContainer = UIView()
        countdownContainer.translatesAutoresizingMaskIntoConstraints = false
        countdownContainer.addSubview(otpCountdown!)
        countdownContainer.addSubview(startLabel!)
        countdownContainer.addSubview(expirationLabel!)
        countdownContainer.addSubview(endLabel!)
        
        // Create delete button
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle(isArabicSelected ? "حذف" : "DELETE", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 8
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        deleteButton.contentHorizontalAlignment = .center
        deleteButton.titleEdgeInsets = isArabicSelected ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20) : UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(Deletetoken), for: .touchUpInside)
        
        // Add subviews to stackView
//        stackView.addArrangedSubview(nameLabel!)
        stackView.addArrangedSubview(otpLabel!)
        stackView.addArrangedSubview(countdownContainer)
//        stackView.addArrangedSubview(deleteButton)
        stackView.setCustomSpacing(30, after: otpLabel!)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Bank image view constraints
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            bankImageView.heightAnchor.constraint(equalTo: bankImageView.widthAnchor, multiplier: 0.533),
            
            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 20),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            whiteBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            // Token label constraints
            tokenLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            tokenLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            tokenLabel.leadingAnchor.constraint(greaterThanOrEqualTo: whiteBackgroundView.leadingAnchor, constant: 20),
            tokenLabel.trailingAnchor.constraint(lessThanOrEqualTo: whiteBackgroundView.trailingAnchor, constant: -20),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20),
            
            // otpCountdown constraints within countdownContainer
            otpCountdown!.leadingAnchor.constraint(equalTo: countdownContainer.leadingAnchor, constant: 0),
            otpCountdown!.trailingAnchor.constraint(equalTo: countdownContainer.trailingAnchor, constant: 0),
            otpCountdown!.topAnchor.constraint(equalTo: countdownContainer.topAnchor),
            otpCountdown!.heightAnchor.constraint(equalToConstant: 10),
            
            // Start label ("0") constraints
            startLabel!.leadingAnchor.constraint(equalTo: countdownContainer.leadingAnchor),
            startLabel!.topAnchor.constraint(equalTo: otpCountdown!.bottomAnchor, constant: 5),
            
            // Expiration label constraints
            expirationLabel!.centerXAnchor.constraint(equalTo: countdownContainer.centerXAnchor),
            expirationLabel!.topAnchor.constraint(equalTo: otpCountdown!.bottomAnchor, constant: 5),
            
            // End label ("30") constraints
            endLabel!.trailingAnchor.constraint(equalTo: countdownContainer.trailingAnchor),
            endLabel!.topAnchor.constraint(equalTo: otpCountdown!.bottomAnchor, constant: 5),
            
            // Ensure countdownContainer has enough height
            countdownContainer.bottomAnchor.constraint(equalTo: startLabel!.bottomAnchor),
            
            // Delete button height
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Retrieve ETIdentity
        let defaults = UserDefaults.standard
        if let serialNumber = serialNumber,
           let identityData = defaults.data(forKey: "savedIdentity_\(serialNumber)") {
            do {
                if let retrievedIdentity = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(identityData) as? ETIdentity {
                    identity = retrievedIdentity
                }
            } catch {
                print("")
            }
        }
        
        // Initialize countdown with manageOTPCountdown
        if let serialNumber = serialNumber {
            let (otp, timestamp) = manageOTPCountdown(
                identity: identity,
                lastOtpUpdate: lastOtpUpdate,
                otpLabel: otpLabel,
                otpCountdown: otpCountdown,
                serialNumber: serialNumber
            )
            lastOtpUpdate = timestamp
            if let otp = otp ?? savedOTP, !otp.isEmpty {
                if otp.count >= 6 {
                        let x = otp.count / 2
                        let index = otp.index(otp.startIndex, offsetBy: x)
                        let formattedOtp = otp[..<index] + "-" + otp[index...]
                         // Output: e.g., "123-456" for "123456"
                    otpLabel?.text = String(formattedOtp)
                    }
                
//                otpLabel?.text = otp
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    @objc func Deletetoken() {
        guard let tokenNameToDelete = tokenName else {
            showAlert(
                title: isArabicSelected ? "خطأ" : "Error",
                message: isArabicSelected ? "لم يتم توفير اسم الرمز." : "No token name provided."
            )
            return
        }
        
        let confirmationAlert = UIAlertController(
            title: isArabicSelected ? "تأكيد الحذف" : "Confirm Deletion",
            message: isArabicSelected ? "هل أنت متأكد أنك تريد حذف الرمز '\(tokenNameToDelete)'؟" : "Are you sure you want to delete the token '\(tokenNameToDelete)'?",
            preferredStyle: .alert
        )
        
        confirmationAlert.addAction(UIAlertAction(
            title: isArabicSelected ? "إلغاء" : "Cancel",
            style: .cancel) { _ in
                print("")
            })
        
        confirmationAlert.addAction(UIAlertAction(
            title: isArabicSelected ? "حذف" : "Delete",
            style: .destructive) { _ in
                self.performTokenDeletion(tokenNameToDelete)
            })
        
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    
    private func performTokenDeletion(_ tokenNameToDelete: String) {
        let defaults = UserDefaults.standard
        
        // Retrieve and decrypt saved tokens
        var savedTokens: [[String: String]] = (defaults.object(forKey: "savedTokens") as? Data)
            .flatMap { try? EncryptionHelper.shared.decrypt($0) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [[String: String]] } ?? []
        
        if savedTokens.isEmpty {
            showAlert(
                title: isArabicSelected ? "خطأ" : "Error",
                message: isArabicSelected ? "لم يتم العثور على رموز محفوظة." : "No saved tokens found."
            )
            return
        }
        
        if let index = savedTokens.firstIndex(where: { $0["tokenName"] == tokenNameToDelete }) {
            let serialNumber = savedTokens[index]["serialNumber"] ?? ""
            savedTokens.remove(at: index)
            
            // Save the updated (encrypted) tokens back to UserDefaults
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: savedTokens, options: [])
                let encryptedData = try EncryptionHelper.shared.encrypt(jsonData)
                defaults.set(encryptedData, forKey: "savedTokens")
            } catch {
                print("")
            }
            
            // Remove associated data
            defaults.removeObject(forKey: "savedOTP_\(serialNumber)")
            defaults.removeObject(forKey: "lastOtpUpdate_\(serialNumber)")
            defaults.removeObject(forKey: "savedIdentity_\(serialNumber)")
            
            defaults.synchronize()
            
            // Show success alert with navigation
            let alert = UIAlertController(
                title: isArabicSelected ? "نجاح" : "Success",
                message: isArabicSelected ? "تم حذف الرمز '\(tokenNameToDelete)' بنجاح." : "Token '\(tokenNameToDelete)' has been deleted.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: isArabicSelected ? "حسنًا" : "OK",
                style: .default) { _ in
                    let startVC = startViewController()
                    self.navigationController?.pushViewController(startVC, animated: true)
                })
            
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(
                title: isArabicSelected ? "خطأ" : "Error",
                message: isArabicSelected ? "لم يتم العثور على الرمز '\(tokenNameToDelete)'." : "Token '\(tokenNameToDelete)' not found."
            )
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func manageOTPCountdown(
        identity: ETIdentity?,
        lastOtpUpdate: Date?,
        otpLabel: UILabel?,
        otpCountdown: UIProgressView?,
        serialNumber: String
    ) -> (otp: String?, timestamp: Date?) {
        countdownTimer?.invalidate()
        
        let defaults = UserDefaults.standard
        let otpKey = "savedOTP_\(serialNumber)"
        let timestampKey = "lastOtpUpdate_\(serialNumber)"
        
        var currentOtp: String?
        var currentTimestamp: Date?
        
        if let savedTimestamp = defaults.object(forKey: timestampKey) as? Date,
           let savedOtp = defaults.string(forKey: otpKey) {
            let timeSinceLastOtp = -savedTimestamp.timeIntervalSinceNow
            if timeSinceLastOtp < ET_OTP_VALIDITY_PERIOD {
                currentOtp = savedOtp
                currentTimestamp = savedTimestamp
                otpLabel?.text = currentOtp
                otpCountdown?.progress = Float(1.0 - (timeSinceLastOtp / ET_OTP_VALIDITY_PERIOD))
            }
        }
        
        if currentOtp == nil {
            currentTimestamp = Date()
            currentOtp = identity?.getOTP(currentTimestamp)
            otpLabel?.text = currentOtp
            otpCountdown?.progress = 1.0
            
            if let otp = currentOtp {
                defaults.set(otp, forKey: otpKey)
                defaults.set(currentTimestamp, forKey: timestampKey)
                defaults.synchronize()
            }
        }
        
        otpLabel?.isHidden = false
        otpCountdown?.isHidden = false
        startLabel?.isHidden = false
        expirationLabel?.isHidden = false
        endLabel?.isHidden = false
        
        var localTimestamp = currentTimestamp
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            guard let lastUpdate = localTimestamp else {
                timer.invalidate()
                return
            }
            
            let timeSinceLastOtp = -lastUpdate.timeIntervalSinceNow
            let validityPeriod = Float(ET_OTP_VALIDITY_PERIOD)
            let progress = max(0.0, min(1.0, Float(1.0 - (timeSinceLastOtp / Double(validityPeriod)))))
            
            if timeSinceLastOtp >= Double(validityPeriod) {
                localTimestamp = Date()
                let newOtp = identity?.getOTP(localTimestamp)
//                otpLabel?.text = newOtp
                if let otp = newOtp, otp.count >= 6 {
                    let x = otp.count / 2
                    let index = otp.index(otp.startIndex, offsetBy: x)
                    let formattedOtp = otp[..<index] + "-" + otp[index...]
                    otpLabel?.text = String(formattedOtp)
                }
                otpCountdown?.progress = 1.0
                
                defaults.set(newOtp, forKey: otpKey)
                defaults.set(localTimestamp, forKey: timestampKey)
                defaults.synchronize()
            } else {
                otpCountdown?.progress = progress
            }
        }
        
        return (currentOtp, localTimestamp)
    }
}
