//
//  TokenDeleteRecord.swift
//  Riyadbank SG
//
//  Created by MacBook Pro on 05/05/2025.
//


import UIKit
import EntrustIGMobile

class TokenDeleteRecord: UIViewController {
    
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
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        navigationItem.hidesBackButton = true
        
        // Create stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set background color
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        // Create white background view
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 15
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Token Name Title
        let tokenNameTitle = UILabel()
        tokenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        tokenNameTitle.text = isArabicSelected ? "اسم الرمز" : "Token Name"
        tokenNameTitle.textColor = .black
        tokenNameTitle.textAlignment = .center
        tokenNameTitle.font = isArabicSelected ?
            UIFont(name: "RBType-RB-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20) :
            UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        // Token Name Layer
        let tokenNameLayer = UIView()
        tokenNameLayer.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        tokenNameLayer.layer.cornerRadius = 6
        tokenNameLayer.clipsToBounds = true
        tokenNameLayer.translatesAutoresizingMaskIntoConstraints = false
        
        let tokenNameLabel = UILabel()
        tokenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenNameLabel.text = self.tokenName
        tokenNameLabel.clipsToBounds = true
        tokenNameLabel.textAlignment = .center
        tokenNameLabel.font = isArabicSelected ?
            UIFont(name: "RBType-RB-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18) :
            UIFont.systemFont(ofSize: 18)
        tokenNameLayer.addSubview(tokenNameLabel)
        
        // Serial Number Title
        let serialNumberTitle = UILabel()
        serialNumberTitle.translatesAutoresizingMaskIntoConstraints = false
        serialNumberTitle.text = isArabicSelected ? " الرقم التسلسلي " : "Serial Number"
        serialNumberTitle.textColor = .black
        serialNumberTitle.textAlignment = .center
        serialNumberTitle.font = isArabicSelected ?
            UIFont(name: "RBType-RB-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20) :
            UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        // Serial Number Layer
        let serialNumberLayer = UIView()
        serialNumberLayer.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        serialNumberLayer.layer.cornerRadius = 6
        serialNumberLayer.clipsToBounds = true
        serialNumberLayer.translatesAutoresizingMaskIntoConstraints = false
        
        let serialNumberLabel = UILabel()
        serialNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        serialNumberLabel.text = self.serialNumber
        serialNumberLabel.textColor = .black
        serialNumberLabel.textAlignment = .center
        serialNumberLabel.font = isArabicSelected ?
            UIFont(name: "RBType-RB-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18) :
            UIFont.systemFont(ofSize: 18)
        serialNumberLayer.addSubview(serialNumberLabel)
        
        // Delete Button
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle(isArabicSelected ? "إلغاء" : "DELETE", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 8
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        deleteButton.contentHorizontalAlignment = .center
        deleteButton.titleEdgeInsets = isArabicSelected ?
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20) :
            UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(Deletetoken), for: .touchUpInside)
        
        // Add views to stack view
        stackView.addArrangedSubview(tokenNameTitle)
        stackView.addArrangedSubview(tokenNameLayer)
        stackView.addArrangedSubview(serialNumberTitle)
        stackView.addArrangedSubview(serialNumberLayer)
        stackView.addArrangedSubview(deleteButton)
        
        // Add whiteBackgroundView and stackView to view hierarchy
        view.addSubview(whiteBackgroundView)
        whiteBackgroundView.addSubview(stackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Bank image view constraints
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            bankImageView.heightAnchor.constraint(equalTo: bankImageView.widthAnchor, multiplier: 0.533),
            
            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 40),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            whiteBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20),
            
            // Token name label constraints
            tokenNameLabel.centerXAnchor.constraint(equalTo: tokenNameLayer.centerXAnchor),
            tokenNameLabel.centerYAnchor.constraint(equalTo: tokenNameLayer.centerYAnchor),
            tokenNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tokenNameLayer.leadingAnchor, constant: 10),
            tokenNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: tokenNameLayer.trailingAnchor, constant: -10),
            
            // Serial number label constraints
            serialNumberLabel.centerXAnchor.constraint(equalTo: serialNumberLayer.centerXAnchor),
            serialNumberLabel.centerYAnchor.constraint(equalTo: serialNumberLayer.centerYAnchor),
            serialNumberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: serialNumberLayer.leadingAnchor, constant: 10),
            serialNumberLabel.trailingAnchor.constraint(lessThanOrEqualTo: serialNumberLayer.trailingAnchor, constant: -10),
            
            // Layer height constraints
            tokenNameLayer.heightAnchor.constraint(equalToConstant: 35),
            serialNumberLayer.heightAnchor.constraint(equalToConstant: 35),
            
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
                    if let otp = retrievedIdentity.getOTP(Date()) {
                        self.otpLabel?.text = otp
                    }
                }
            } catch {
                print("")
            }
        }
        
        if identity != nil {
            // Generate initial OTP and start the timer
            if let initialOTP = generateOTP() {
                self.otpLabel?.text = initialOTP
            }
        }
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
                print("Failed to encrypt updated tokens: \(error)")
            }
            
            // Remove associated data using serialNumber
            defaults.removeObject(forKey: "savedOTP_\(serialNumber)")
            
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
                    let callUsVC = SettingsViewController()
                    self.navigationController?.pushViewController(callUsVC, animated: true)
            })
            self.present(alert, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: "Token '\(tokenNameToDelete)' not found")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func generateOTP() -> String? {
        lastOtpUpdate = Date()
        guard let identity = identity else {
            return nil
        }
        
        let otp = identity.getOTP(lastOtpUpdate)
        self.otpLabel?.text = otp
        self.otpCountdown?.progress = 1.0
        
        if let otp = otp {
            let defaults = UserDefaults.standard
            defaults.set(otp, forKey: "savedOTP")
            defaults.synchronize()
        }
        
        self.otpLabel?.isHidden = false
        self.otpCountdown?.isHidden = false
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                              target: self,
                                              selector: #selector(updateCountdownProgress(sender:)),
                                              userInfo: nil, repeats: true)
        
        return otp
    }
    
    @objc func updateCountdownProgress(sender: Timer) {
        guard let lastOtpUpdate = lastOtpUpdate else {
            return
        }
        
        let timeSinceLastOtp = -lastOtpUpdate.timeIntervalSinceNow
        let progress: Float = Float(1.0 - (timeSinceLastOtp / ET_OTP_VALIDITY_PERIOD))
        
        if progress <= 0.0 {
            self.lastOtpUpdate = Date()
            self.otpLabel?.text = identity?.getOTP(self.lastOtpUpdate)
            self.otpCountdown?.progress = 1.0
        } else {
            self.otpCountdown?.progress = progress
        }
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}
