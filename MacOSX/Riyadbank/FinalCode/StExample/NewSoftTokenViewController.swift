import UIKit
import EntrustIGMobile
import AVFoundation
import VisionKit
import CryptoKit
import CommonCrypto
import Foundation
import CoreImage

class NewSoftTokenViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let imagePicker = UIImagePickerController()
    
    
    
    var serialNumberField: UITextField!
    var activationCodeField: UITextField!
//    var registrationCodeField: UITextField!
    var serialNumberOkView: UIImageView!
    var activationCodeOkView: UIImageView!
    var otpLabel: UILabel!
    var currentOtp: UILabel!
    var titleLabels: [UILabel] = []
    
    var nameLabel: UILabel!
    var tokenNameLabel: UILabel!
    var serialNumberLabel: UILabel!
    var activationCodeLabel: UILabel!
    var startLabel: UILabel!
    var endLabel: UILabel!
    var expirationLabel: UILabel!
    
    var registrationCodelabel: UILabel!
    var registrationCodetext: UILabel!
    var registrationCodeField: UILabel!
    var securityCodelabel: UILabel!
    var securityCodetext: UILabel!
    var titleLabel: UILabel!
    var otpCountdown: UIProgressView!
    var version: UILabel!
    var tokenNameField: UITextField!
    private let languageButton = UIButton(type: .system)

    // Variables related to the identity and OTP generation
    private var identity: ETIdentity?
    private var countdownTimer: Timer?
    private var lastOtpUpdate: Date?
    var nextButton: UIButton!
    var qrButton: UIButton!
    private var addTokenButton: UIButton!
    private var tokenButton: UIButton!
    private var currentStep: Int = 0
    var stepView: UIStackView?
    private var whiteBackgroundBottomConstraint: NSLayoutConstraint?
    private var whiteBackgroundView: UIView!
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    


    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        navigationItem.hidesBackButton = true
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        
        ETSoftTokenSDK.setLogLevel(ETLogLevelOff)
        ETSoftTokenSDK.initializeSDK()

        // Create scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create white background view
        whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = .white
        whiteBackgroundView.layer.cornerRadius = 10
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(whiteBackgroundView)

        // Constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -40),
            whiteBackgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -80),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40)
        ])

        setupStepProgressIndicator(on: whiteBackgroundView)
        setupInputFields(on: whiteBackgroundView)
        setupNextButton(on: whiteBackgroundView)
        
        nextButton.isHidden = false
        tokenNameField.isHidden = false
        serialNumberField.isHidden = false
        activationCodeField.isHidden = false
        registrationCodeField.isHidden = true
        
        setupKeyboardObservers()

    }
    
   

    
    private func setupKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc private func keyboardWillShow(notification: Notification) {
            // Move the whiteBackgroundView up by a fixed amount (e.g., 250 points)
            UIView.animate(withDuration: 0.3) {
                self.whiteBackgroundView.transform = CGAffineTransform(translationX: 0, y: -40)
            }
        }
        
        @objc private func keyboardWillHide(notification: Notification) {
            // Reset the whiteBackgroundView to its original position
            UIView.animate(withDuration: 0.3) {
                self.whiteBackgroundView.transform = .identity
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // This will dismiss the keyboard by ending editing on all subviews
    }
 


   
    
    
    





    

    // MARK: - Setup Step Progress Indicator
    func setupStepProgressIndicator(on containerView: UIView) {
        let stepView = UIStackView()
        stepView.axis = .horizontal
        stepView.alignment = .center
        stepView.distribution = .fillProportionally
        stepView.spacing = 20
        
        stepView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stepView)
        
        self.stepView = stepView  // Store the reference
        
        let steps = isArabicSelected ? ["إدخال", "مراجعة", "تأكيد"] : ["Input", "Review", "Confirm"] // Changed to apply language-specific text
        let activeIndex = currentStep
        var previousCircle: UIView?

        for (index, step) in steps.enumerated() {
            let stepContainer = UIView()
            
            let circle = UIView()
            circle.layer.cornerRadius = 20
            circle.backgroundColor = index == activeIndex ? UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            ) : UIColor.white
            circle.layer.borderWidth = index == activeIndex ? 0 : 2
            circle.layer.borderColor = UIColor.lightGray.cgColor
            circle.translatesAutoresizingMaskIntoConstraints = false
            stepContainer.addSubview(circle)
            
            let numberLabel = UILabel()
            numberLabel.text = "\(index + 1)"
            numberLabel.textColor = index == activeIndex ? UIColor.white : UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            )
            numberLabel.textAlignment = .center
            numberLabel.font = UIFont.boldSystemFont(ofSize: 16)
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            circle.addSubview(numberLabel)
            
            let titleLabel = UILabel()
            titleLabel.text = step
            titleLabel.textColor = index == activeIndex ? UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1) : UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1)
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            stepContainer.addSubview(titleLabel)
            
            stepView.addArrangedSubview(stepContainer)
            
            if let prev = previousCircle {
                let line = UIView()
                line.backgroundColor = UIColor.lightGray
                line.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(line)
                
                NSLayoutConstraint.activate([
                    line.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                    line.heightAnchor.constraint(equalToConstant: 2),
                    line.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 10),
                    line.trailingAnchor.constraint(equalTo: circle.leadingAnchor, constant: -10)
                ])
            }
            previousCircle = circle
            
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 40),
                circle.heightAnchor.constraint(equalToConstant: 40),
                circle.topAnchor.constraint(equalTo: stepContainer.topAnchor),
                circle.centerXAnchor.constraint(equalTo: stepContainer.centerXAnchor),
                
                numberLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                numberLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
                
                titleLabel.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 5),
                titleLabel.centerXAnchor.constraint(equalTo: stepContainer.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: stepContainer.bottomAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            stepView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stepView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stepView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stepView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Setup Input Fields
    func setupInputFields(on containerView: UIView) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = view.frame.height * 0.015 // 1.5% of screen height
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        qrButton = UIButton(type: .system)
        qrButton.setTitle(isArabicSelected ? "مسح الکود " : "Scan QR Code", for: .normal)
        qrButton.setTitleColor(.white, for: .normal)
        qrButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        qrButton.layer.cornerRadius = 8
//        qrButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        qrButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 18)
        qrButton.addTarget(self, action: #selector(ScanQRCode), for: .touchUpInside)
        
        

            // Create text fields
        tokenNameLabel = UILabel()
                tokenNameLabel.text = isArabicSelected ? "اسم الرمز" : "Token Name"
                tokenNameLabel.textAlignment = isArabicSelected ? .right : .left // Changed to apply language-specific alignment
                tokenNameLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                tokenNameLabel.textColor = .black
                tokenNameLabel.translatesAutoresizingMaskIntoConstraints = false

        serialNumberLabel = UILabel()
                serialNumberLabel.text = isArabicSelected ? "الرقم التسلسلي" : "Serial Number" // Added Arabic for consistency
                serialNumberLabel.textAlignment = isArabicSelected ? .right : .left // Changed to apply language-specific alignment
                serialNumberLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                serialNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        activationCodeLabel = UILabel()
                activationCodeLabel.text = isArabicSelected ? "رمز التفعيل" : "Activation Number" // Added Arabic for consistency
                activationCodeLabel.textAlignment = isArabicSelected ? .right : .left // Changed to apply language-specific alignment
                activationCodeLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
                activationCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        serialNumberLabel.textColor = .black
        activationCodeLabel.textColor = .black
//        tokenNameLabel.textColor = .black
        
        
        registrationCodetext = UILabel()
        registrationCodetext.text = isArabicSelected ? "الرجاء إدخال الرمز التالي في موقع بنك الرياض" : "Please enter the following code in Riyad Bank website"
        registrationCodetext.textAlignment = isArabicSelected ? .right : .left
        registrationCodetext.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20) : UIFont.systemFont(ofSize: 17)
        registrationCodetext.textColor = .black
        registrationCodetext.numberOfLines = 0
        registrationCodetext.translatesAutoresizingMaskIntoConstraints = false

        
        registrationCodelabel = UILabel()
        registrationCodelabel.text = isArabicSelected ? "رمز التسجيل" : "Registration Code"
        registrationCodelabel.textAlignment = .center
        registrationCodelabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 26) ?? UIFont.systemFont(ofSize: 26) : UIFont.systemFont(ofSize: 26)
        registrationCodelabel.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
        registrationCodelabel.translatesAutoresizingMaskIntoConstraints = false

        
        registrationCodeField = UILabel()
        registrationCodeField.text = ""
        registrationCodeField.textAlignment = .center
        registrationCodeField.font = UIFont.boldSystemFont(ofSize: 30)
        registrationCodeField.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
        registrationCodeField.translatesAutoresizingMaskIntoConstraints = false
        
        registrationCodelabel.isHidden = true
        registrationCodetext.isHidden = true

        // Assuming you have a createTextField method, if not, here's a simple version:
        
        securityCodetext = UILabel()
        securityCodetext.text = isArabicSelected ? "تم التسجيل بنجاح. يمكنك استخدام رمزالحماية بعد استلام رسالة التفيل" : "Registration is successful, you can use the security code for authentication after activation SMS"
        securityCodetext.textAlignment = isArabicSelected ? .right : .left
        securityCodetext.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20) : UIFont.systemFont(ofSize: 20)
        securityCodetext.numberOfLines = 0
        securityCodetext.textColor = .black
        securityCodetext.translatesAutoresizingMaskIntoConstraints = false

        
        securityCodelabel = UILabel()
        securityCodelabel.text = isArabicSelected ? "رمز التفعيل" : "Security Code"
        securityCodelabel.textAlignment = .center
        securityCodelabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 26) ?? UIFont.systemFont(ofSize: 26) : UIFont.systemFont(ofSize: 26)
        securityCodelabel.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
        securityCodelabel.translatesAutoresizingMaskIntoConstraints = false

        
        securityCodelabel.isHidden = true
        securityCodetext.isHidden = true
        
        

        // Create text fields
        tokenNameField = createTextField(placeholder: isArabicSelected ? "حدداسم " : "Enter token name")
        serialNumberField = createTextField(placeholder: isArabicSelected ? "12345 12345" : "Enter serial number")
        activationCodeField = createTextField(placeholder: isArabicSelected ? "1234 1234 1234 1234" : "Enter activation number")

//        registrationCodeField = createTextField(placeholder: "Enter registration code")
        serialNumberField.delegate = self
        activationCodeField.delegate = self
        
        tokenNameField.keyboardType = .default
        registrationCodeField.isHidden = true
            nameLabel = UILabel()
            nameLabel.textAlignment = .center
            nameLabel.font = UIFont.systemFont(ofSize: 18)
            nameLabel.textColor = UIColor.black
            nameLabel.isHidden = true
            nameLabel.translatesAutoresizingMaskIntoConstraints = false

            // OTP label
            otpLabel = UILabel()
            otpLabel.textAlignment = .center
//            otpLabel.font = UIFont.systemFont(ofSize: 18)
            otpLabel.textColor = UIColor.black
            otpLabel.font = UIFont.boldSystemFont(ofSize: 30)
            otpLabel.textColor = UIColor(red: 0/255, green: 128/255, blue: 96/255, alpha: 1.0)
            otpLabel.isHidden = true
            otpLabel.translatesAutoresizingMaskIntoConstraints = false
            
        
            otpCountdown = UIProgressView(progressViewStyle: .default)
            otpCountdown.progressTintColor = UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 1.0)
            otpCountdown.trackTintColor = UIColor.lightGray
            otpCountdown.progress = 1.0
            otpCountdown.isHidden = true
            otpCountdown.translatesAutoresizingMaskIntoConstraints = false
        
            startLabel = UILabel()
            startLabel.translatesAutoresizingMaskIntoConstraints = false
            startLabel.text = "0"
            startLabel.textColor = .black
            startLabel.font = UIFont.systemFont(ofSize: 14)
            
        expirationLabel = UILabel()
        expirationLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationLabel.text = isArabicSelected ? "مدةالصلاحية" : "Expiration Time"
        expirationLabel.textColor = .black
        expirationLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        expirationLabel.textAlignment = .center

            
            endLabel = UILabel()
            endLabel.translatesAutoresizingMaskIntoConstraints = false
            endLabel.text = "30"
            endLabel.textColor = .black
            endLabel.font = UIFont.systemFont(ofSize: 14)
        
            endLabel.isHidden = true
            expirationLabel.isHidden = true
            startLabel.isHidden = true
            let countdownContainer = UIView()
            countdownContainer.translatesAutoresizingMaskIntoConstraints = false
            
            // Add otpCountdown and labels to the container
            countdownContainer.addSubview(otpCountdown)
            countdownContainer.addSubview(startLabel)
            countdownContainer.addSubview(expirationLabel)
            countdownContainer.addSubview(endLabel)
        
        
        
        let spacingoneline = UILabel()
        spacingoneline.text = ""
        spacingoneline.textAlignment = .center
        
        spacingoneline.font = UIFont.systemFont(ofSize: 9)
        spacingoneline.textColor = .white
        spacingoneline.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(spacingoneline)
        
            stackView.addArrangedSubview(qrButton)
            stackView.addArrangedSubview(tokenNameLabel)
            stackView.addArrangedSubview(tokenNameField)
            stackView.addArrangedSubview(serialNumberLabel)
            stackView.addArrangedSubview(serialNumberField)
            stackView.addArrangedSubview(activationCodeLabel)
            stackView.addArrangedSubview(activationCodeField)
            stackView.addArrangedSubview(registrationCodetext)
            stackView.addArrangedSubview(registrationCodelabel)
            stackView.addArrangedSubview(registrationCodeField)
            stackView.addArrangedSubview(securityCodetext)
            stackView.addArrangedSubview(securityCodelabel)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(otpLabel)
//            stackView.addArrangedSubview(otpCountdown)
            stackView.addArrangedSubview(countdownContainer)

            // Optional: Add some spacing between labels and text fields
            stackView.setCustomSpacing(view.frame.height * 0.05, after: registrationCodetext) // ~5% of screen height
            stackView.setCustomSpacing(view.frame.height * 0.025, after: registrationCodelabel) // ~2.5%
            stackView.setCustomSpacing(view.frame.height * 0.05, after: securityCodetext)
            stackView.setCustomSpacing(view.frame.height * 0.025, after: securityCodelabel)
            
            // Add stack view to containerView
            containerView.addSubview(stackView)
        guard let stepView = self.stepView else {
                
                return
            }

            // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: view.frame.height * 0.1), // 10% of screen height
                    stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                    stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                    stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20),
                    
                    otpCountdown.leadingAnchor.constraint(equalTo: countdownContainer.leadingAnchor, constant: 0),
                    otpCountdown.trailingAnchor.constraint(equalTo: countdownContainer.trailingAnchor, constant: 0),
                    otpCountdown.topAnchor.constraint(equalTo: countdownContainer.topAnchor),
                    otpCountdown.heightAnchor.constraint(equalToConstant: 10), // Adjust height as needed
                    
                    // Start label ("0") constraints
                    startLabel.leadingAnchor.constraint(equalTo: countdownContainer.leadingAnchor),
                    startLabel.topAnchor.constraint(equalTo: otpCountdown.bottomAnchor, constant: 5),
                    
                    // Expiration label constraints
                    expirationLabel.centerXAnchor.constraint(equalTo: countdownContainer.centerXAnchor),
                    expirationLabel.topAnchor.constraint(equalTo: otpCountdown.bottomAnchor, constant: 5),
                    
                    // End label ("30") constraints
                    endLabel.trailingAnchor.constraint(equalTo: countdownContainer.trailingAnchor),
                    endLabel.topAnchor.constraint(equalTo: otpCountdown.bottomAnchor, constant: 5),
                    
                    
                    // Ensure countdownContainer has enough height
                    countdownContainer.bottomAnchor.constraint(equalTo: startLabel.bottomAnchor)
                ])

        }
        
        // MARK: - TextField Validation
    private func createTextField(placeholder: String) -> UITextField {
            let textField = UITextField()
            textField.placeholder = placeholder
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.keyboardType = .numberPad // Use number pad for serialNumberField and activationCodeField
        textField.backgroundColor = .white // Set background color to white
            textField.textColor = .black // Set input text color to black
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.textAlignment = isArabicSelected ? .right : .left
            
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
            return textField
        }
        
        // MARK: - UITextFieldDelegate
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Get the current text, excluding the replacement range
            guard let currentText = textField.text as NSString? else { return true }
            let newText = currentText.replacingCharacters(in: range, with: string)
            
            // Define allowed characters
            let allowedCharacters = CharacterSet.decimalDigits
            let isValidInput = string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
            
            if textField == tokenNameField {
                // Allow only letters and spaces for token name
                let allowedCharactersForName = CharacterSet.letters.union(.whitespaces)
                return string.rangeOfCharacter(from: allowedCharactersForName.inverted) == nil
            }
            
            if textField == serialNumberField {
                // Allow only digits
                guard isValidInput else { return false }
                
                // Remove spaces for counting digits
                let digitsOnly = newText.replacingOccurrences(of: " ", with: "")
                
                // Limit to 10 digits
                if digitsOnly.count > 10 { return false }
                
                // Format with space after 5 digits
                if digitsOnly.count > 5 {
                    let firstPart = String(digitsOnly.prefix(5))
                    let secondPart = String(digitsOnly.dropFirst(5))
                    textField.text = "\(firstPart) \(secondPart)"
                } else {
                    textField.text = digitsOnly
                }
                
                return false // Prevent default input since we manually set the text
            }
            
            if textField == activationCodeField {
                // Allow only digits
                guard isValidInput else { return false }
                
                // Remove spaces for counting digits
                let digitsOnly = newText.replacingOccurrences(of: " ", with: "")
                
                // Limit to 16 digits
                if digitsOnly.count > 16 { return false }
                
                // Format with spaces after every 4 digits
                let formattedText = formatActivationCode(digitsOnly)
                textField.text = formattedText
                
                return false // Prevent default input since we manually set the text
            }
            
            return true
        }
        
        // Helper function to format activation code with spaces every 4 digits
        private func formatActivationCode(_ digits: String) -> String {
            var formatted = ""
            let characters = Array(digits)
            
            for (index, char) in characters.enumerated() {
                if index > 0 && index % 4 == 0 {
                    formatted += " "
                }
                formatted += String(char)
            }
            
            return formatted
        }

    // MARK: - Setup Next Button
    func setupNextButton(on containerView: UIView) {
        nextButton = UIButton(type: .system)
        nextButton.setTitle(isArabicSelected ? "التالي  " : " NEXT  ", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        nextButton.layer.cornerRadius = 8
        nextButton.titleLabel?.font = isArabicSelected ?
        UIFont(name: "RBType-RB-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) :
        UIFont.boldSystemFont(ofSize: 18)
//        nextButton.contentHorizontalAlignment = isArabicSelected ? .right : .left // Adjust button text alignment


        // Add arrow image
        if #available(iOS 13.0, *) {
            let arrowImage = UIImage(systemName: "chevron.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            nextButton.setImage(arrowImage, for: .normal)
        } else {
            let arrowImage = UIImage(named: "arrow_right") // Provide a fallback image from assets
            nextButton.setImage(arrowImage, for: .normal)
        }

        nextButton.semanticContentAttribute = .forceRightToLeft
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        containerView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: activationCodeField.bottomAnchor, constant: 30),
            nextButton.topAnchor.constraint(equalTo: registrationCodeField.bottomAnchor, constant: 30),
            nextButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20) // Add padding at the bottom
        ])
    }
    
    

    @objc func openCameraForQRCode() {
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized ||
                  AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else {
                showAlert(message: "Camera access denied")
                return
            }
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCaptureSession()
                        self.captureSession.startRunning()
                    } else {
                        self.showAlert(message: "Camera access denied")
                    }
                }
            }
        }
        
        private func setupCaptureSession() {
            captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                showAlert(message: "No camera available")
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                showAlert(message: "Failed to initialize camera")
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showAlert(message: "Failed to add camera input")
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                showAlert(message: "Failed to add metadata output")
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                           didOutput metadataObjects: [AVMetadataObject],
                           from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               metadataObject.type == .qr,
               let qrCodeString = metadataObject.stringValue {
                captureSession.stopRunning()
                handleQRScannedData(qrData: qrCodeString)
                // Remove the camera preview and clean up
                DispatchQueue.main.async {
                    self.previewLayer.removeFromSuperlayer()
                    self.previewLayer = nil
                    self.captureSession = nil
                }
            }
        }
    
    
    @objc func ScanQRCode() {
        openCameraForQRCode()

        }
    

    
    private func handleQRScannedData(qrData: String) {
        do {
            showPasswordDialog(qrData: qrData)
        } catch {
            
            // Show error toast
            let alert = UIAlertController(
                title: nil,
                message: "Invalid QR Code format",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
             
        }
    }
    

    
    private func showPasswordDialog(qrData: String) {
        let alert = UIAlertController(
            title: "Enter Password",
            message: "Enter your 4-digit code",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
//            textField.delegate = self
            textField.isSecureTextEntry = true
            textField.placeholder = "4-digit code"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let password = textField.text?.trimmingCharacters(in: .whitespaces) else {
                return
            }
            
            if password.isEmpty {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Password cannot be empty",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            if password.count != 4 {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Enter a 4-digit code",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            // Call decryptSecureQR
            self.decryptSecureQR(password: password,qrData: qrData)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    private func decryptSecureQR(password: String, qrData: String) {
        // Validate password
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
                guard !trimmedPassword.isEmpty else {
                    let alert = UIAlertController(
                        title: nil,
                        message: "Password cannot be empty",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    // Clear text fields
                    self.serialNumberField.text = ""
                    self.activationCodeField.text = ""
                    return
                }
        
                    guard let launchURL = URL(string: qrData) else {
                        let alert = UIAlertController(title: "Error", message: "Invalid QR Code format", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }

                    let launchParams = ETSoftTokenSDK.parseLaunch(launchURL)
                    if var secureOfflineParams = launchParams as? ETSecureOfflineActivationLaunchUrlParams {
        
                        var offlineParams2 : ETOfflineActivationLaunchUrlParams? = nil
                            if let offlineParams2 = secureOfflineParams.decrypt(usingPassword: password) {
        
                                let cleanSerialNumber = offlineParams2.serialNumber.replacingOccurrences(of: "-", with: " ")
                                self.serialNumberField.text = cleanSerialNumber
        
                                let cleanactivationCode = offlineParams2.activationCode.replacingOccurrences(of: "-", with: " ")
                                self.activationCodeField.text = cleanactivationCode
        
        
                            } else {
                                // Show alert message
                                let alert = UIAlertController(title: "Error", message: "Your password is incorrect.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                // Assuming this is in a view controller
                                self.present(alert, animated: true, completion: nil)
                            }
                    }
        
        
       
        
    }

    
    
    
    
    

    // MARK: - Handle Next Button Tap
    @objc func buttonTapped() {
        
        
        if currentStep == 0 {
            guard checknameoftoken() else {
                    return // Exit if validation fails
                }
            guard let tokenName = tokenNameField.text, !tokenName.isEmpty,
                          let serialNumber = serialNumberField.text, !serialNumber.isEmpty,
                          let activationCode = activationCodeField.text, !activationCode.isEmpty else {
                showAlert(message: isArabicSelected ? "يرجى ملء جميع الحقول." : "Please fill in all fields.")

                        return
                    }
            
                    // Validate input before moving to the next step
//                    checkCodes()
            if let resultString = checkCodes() as? String {
                if resultString == "false" {
                    return  // Stop execution if validation fails
                }
                let alert = UIAlertController(
                    title: isArabicSelected ? "مهم!" : "Important!",
                    message: isArabicSelected ? "سيتم عرض رمز التسجيل هذا مرة واحدة فقط. يرجى تدوينه" : "This registration code will only be shown once. Please take note",
                    preferredStyle: .alert
                )

                // Add "OK" button
                alert.addAction(UIAlertAction(title: isArabicSelected ? "حسناً" : "OK", style: .default, handler: nil))


                // Show the alert
                present(alert, animated: true, completion: nil)
                currentStep = 1
                updateStepUI()
                registrationCodeField.text = resultString
                tokenNameLabel.isHidden = true
                serialNumberLabel.isHidden = true
                activationCodeLabel.isHidden = true
            } else {
                return // Handle unexpected cases gracefully
            }
                    
                    
                } else if currentStep == 1 {
                    // Move to the "Confirm" step (or perform the next action)
                    currentStep = 2
                    updateStepUI()
                    nextButton.isHidden = true // Start as disabled
//                    nextButton.alpha = 0.5
                    tokenNameLabel.isHidden = true
                    serialNumberLabel.isHidden = true
                    activationCodeLabel.isHidden = true
                    
                }
                updateStepProgressIndicator(to: currentStep)
    }
    


    // MARK: - Update Step UI
    private func updateStepUI() {
        if currentStep == 0 {
            // Show input fields for the "Input" step
            dismissKeyboard()
            tokenNameField.isHidden = false
            serialNumberField.isHidden = false
            activationCodeField.isHidden = false
            tokenNameLabel.isHidden = false
            serialNumberLabel.isHidden = false
            activationCodeLabel.isHidden = false
            registrationCodeField.isHidden = true
            registrationCodelabel.isHidden = true
            registrationCodetext.isHidden = true
            securityCodelabel.isHidden = true
            securityCodelabel.isHidden = true
            otpLabel.isHidden = true
            endLabel.isHidden = true
            expirationLabel.isHidden = true
            startLabel.isHidden = true
        } else if currentStep == 1 {
            // Show the registration code field for the "Review" step
            dismissKeyboard()
            tokenNameField.isHidden = true
            serialNumberField.isHidden = true
            activationCodeField.isHidden = true
            registrationCodeField.isHidden = false
            registrationCodelabel.isHidden = false
            registrationCodetext.isHidden = false
            otpLabel.isHidden = true
            tokenNameLabel.isHidden = true
            serialNumberLabel.isHidden = true
            activationCodeLabel.isHidden = true
            securityCodelabel.isHidden = true
            securityCodetext.isHidden = true
            endLabel.isHidden = true
            expirationLabel.isHidden = true
            startLabel.isHidden = true
            qrButton.isHidden = true
            
            // Set the registration code text
            registrationCodeField.text = identity?.registrationCode
        } else if currentStep == 2 {
            // Show the OTP label for the "Confirm" step
            dismissKeyboard()
            tokenNameField.isHidden = true
            serialNumberField.isHidden = true
            activationCodeField.isHidden = true
            registrationCodeField.isHidden = true
            registrationCodelabel.isHidden = true
            registrationCodetext.isHidden = true
            otpLabel.isHidden = false
            securityCodelabel.isHidden = false
            securityCodetext.isHidden = false
            tokenNameLabel.isHidden = true
            serialNumberLabel.isHidden = true
            activationCodeLabel.isHidden = true
            endLabel.isHidden = false
            expirationLabel.isHidden = false
            startLabel.isHidden = false
            qrButton.isHidden = true
            
            let serialNumber = serialNumberField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            
            let (otp, timestamp) = manageOTPCountdown(
                    identity: identity,
                    lastOtpUpdate: lastOtpUpdate,
                    otpLabel: otpLabel,
                    otpCountdown: otpCountdown,
                    serialNumber: serialNumber
                )
            if let otp1 = otp, otp1.count >= 6 {
                let x = otp1.count / 2
                let index = otp1.index(otp1.startIndex, offsetBy: x)
                let formattedOtp = otp1[..<index] + "-" + otp1[index...]
                otpLabel?.text = String(formattedOtp)
            }
//            otpLabel.text = otp
            
            // Generate and display the OTP
//            if let otp = generateOTP() {
//                otpLabel.text = otp
//            }
        }
    }
    private func generateOTP() -> String? {
        lastOtpUpdate = Date()
        let otp = identity?.getOTP(lastOtpUpdate) // Retrieve OTP from identity
        if let otp1 = otp, otp1.count >= 6 {
            let x = otp1.count / 2
            let index = otp1.index(otp1.startIndex, offsetBy: x)
            let formattedOtp = otp1[..<index] + "-" + otp1[index...]
            otpLabel?.text = String(formattedOtp)
        }
//        otpLabel.text = otp
        otpCountdown.progress = 1.0
        if let otp = otp {
                let defaults = UserDefaults.standard
                defaults.set(otp, forKey: "savedOTP")
                defaults.synchronize() // Ensure it's saved immediately
            }

        // Show the OTP label and countdown
        otpLabel.isHidden = false
        otpCountdown.isHidden = false

        // Start the countdown timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                              target: self,
                                              selector: #selector(updateCountdownProgress(sender:)),
                                              userInfo: nil, repeats: true)

        return otp // Ensure function returns a String? as expected
    }

    // MARK: - Update Step Progress Indicator
    func updateStepProgressIndicator(to step: Int) {
        guard let stepView = self.stepView else { return }
        
        stepView.arrangedSubviews.enumerated().forEach { index, stepContainer in
            guard let circle = stepContainer.subviews.first(where: { $0 is UIView }),
                  let numberLabel = circle.subviews.first(where: { $0 is UILabel }) as? UILabel,
                  let titleLabel = stepContainer.subviews.last as? UILabel else { return }
            
            circle.backgroundColor = index == step ? UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            ) : UIColor.white
            circle.layer.borderWidth = index == step ? 0 : 2
            circle.layer.borderColor = index == step ? UIColor.clear.cgColor : UIColor.lightGray.cgColor
            
            numberLabel.textColor = index == step ? UIColor.white : UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1)
            titleLabel.textColor = index == step ? UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1) : UIColor(red: 0/255, green: 128/255, blue: 128/255, alpha: 1)
        }
    }


    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    private func showAlert1(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let currentVC = self as? UIViewController {
            currentVC.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        }
    }

    // Validation function
    private func checknameoftoken() -> Bool {
        guard let tokenName = tokenNameField.text?.trimmingCharacters(in: .whitespaces),
              !tokenName.isEmpty else {
            showAlert1(
                title: isArabicSelected ? "خطأ" : "Error",
                message: isArabicSelected ? "يرجى إدخال اسم الرمز" : "Please enter a token name"
            )

            return false
        }
        

        let defaults = UserDefaults.standard
            var savedTokens: [[String: String]] = []
            
            if let encryptedData = defaults.object(forKey: "savedTokens") as? Data {
                do {
                    let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
                    if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                       
                    }
                    savedTokens = try JSONSerialization.jsonObject(with: decryptedData, options: []) as? [[String: String]] ?? []
                } catch {
                    print("")
                }
            } else {
                savedTokens = defaults.array(forKey: "savedTokens") as? [[String: String]] ?? []
            }
        
        let nameExists = savedTokens.contains { $0["tokenName"] == tokenName }
        if nameExists {
            showAlert1(
                title: isArabicSelected ? "اسم مكرر" : "Duplicate Name",
                message: isArabicSelected ? "اسم الرمز '\(tokenName)' موجود بالفعل. يرجى اختيار اسم آخر." : "The token name '\(tokenName)' already exists. Please choose a different name."
            )

            return false
        }
        
        return true
    }
    

    
    
   
    private func datasave() {
        let tokenName = tokenNameField.text ?? ""
        let finalTokenName = tokenName.hasSuffix(" ") ? String(tokenName.dropLast()) : tokenName
        let serialNumber = serialNumberField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let activationCode = activationCodeField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        let defaults = UserDefaults.standard
        
        var savedTokens = (defaults.object(forKey: "savedTokens") as? Data).flatMap { try? EncryptionHelper.shared.decrypt($0) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [[String: String]] } ?? []
        
        let newToken: [String: String] = [
            "tokenName": finalTokenName,
            "serialNumber": serialNumber,
            "activationCode": activationCode
        ]
        
        savedTokens.append(newToken)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: savedTokens, options: [])
            let encryptedData = try EncryptionHelper.shared.encrypt(jsonData)
            defaults.set(encryptedData, forKey: "savedTokens")
        } catch {
            print("")
        }
        
        
        if let identity = identity {
            do {
                let identityData = try NSKeyedArchiver.archivedData(withRootObject: identity, requiringSecureCoding: false)
                defaults.set(identityData, forKey: "savedIdentity_\(serialNumber)") // Store identity separately per token
            } catch {
                print("not save identity")
            }
        }
        
        // Rest of your method (identity, OTP, etc.) remains unchanged...
        defaults.synchronize()
    }
    private func loadSavedData(tokenName: String, serialNumber: String, activationCode: String, savedOTP: String) {


        if identity != nil {
            
            
            nextButton.isEnabled = false // Start as disabled
            nextButton.alpha = 0.5
            currentStep = 2
            updateStepUI()
            updateStepProgressIndicator(to: currentStep)

            if !savedOTP.isEmpty {
                
                otpLabel.text = savedOTP
                
            }
        }
    }


    
    private func invalidCodes() {

        if self.identity != nil {
            self.identity = nil
        }

        if self.countdownTimer != nil {
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil
        }

        if self.lastOtpUpdate != nil {
            self.lastOtpUpdate = nil
        }

    }
    
    @objc func updateCountdownProgress(sender: Timer) {

        if let lastOtpUpdate = lastOtpUpdate {
            let timeSinceLastOtp = -lastOtpUpdate.timeIntervalSinceNow
            let progress: Float = Float(1.0 - (timeSinceLastOtp / ET_OTP_VALIDITY_PERIOD))

            if progress <= 0.0 {
                // Time for a new OTP
                self.lastOtpUpdate = Date()
                let newOtp = identity?.getOTP(self.lastOtpUpdate)
                if let otp = newOtp, otp.count >= 6 {
                    let x = otp.count / 2
                    let index = otp.index(otp.startIndex, offsetBy: x)
                    let formattedOtp = otp[..<index] + "-" + otp[index...]
                    otpLabel?.text = String(formattedOtp)
                }
                otpCountdown.progress = 1.0
            } else {
                // Current OTP is still OK, update the progress.
                otpCountdown.progress = progress
            }

        }

    }
    
    private func checkCodes()-> Any? {


        var activationCodeOkay = false

        do {
            
            let activationCode1 = activationCodeField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            
            
            guard let activationCode = activationCodeField.text, activationCode.count == 19 else {
                showAlert(
                    message: isArabicSelected ? "يجب أن يحتوي حقل التفعيل دائمًا على 16 حرفًا." : "Activation field value must always be 16 characters."
                )

                return "false"
            }
            
            try ETIdentityProvider.validateActivationCode(activationCode)
            activationCodeOkay = true
        } catch let error {
            activationCodeOkay = false
            showAlert(
                message: isArabicSelected ? "رمز التفعيل غير صالح. يرجى إدخال رمز التفعيل الصحيح." : "Activation code is invalid. Please enter the correct activation code."
            )

            self.invalidCodes()
            return "false"
        }
        if activationCodeOkay {
            activationCodeField.resignFirstResponder()
        }

        var serialNumberOkay = false
        do {
            // NSError *error = nil;
            // [ETIdentityProvider validateSerialNumber:serialNumberField.text];
            let serialNumber = serialNumberField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            try  ETIdentityProvider.validateSerialNumber(serialNumber)
            serialNumberOkay = true

        } catch let error {
            // Serial number is not valid.
//            serialNumberOkView.isHidden = true
            showAlert(
                message: isArabicSelected ? "الرقم التسلسلي غير صالح. يرجى إدخال الرقم التسلسلي الصحيح." : "Serial number is invalid. Please enter the correct serial number."
            )

            self.invalidCodes()
            return "false"
        }
        if serialNumberOkay {
            // If we get here then the string is valid.
            // Hide the keyboard if required, and show the "serial number is valid" image
            self.serialNumberField.resignFirstResponder()
//            self.serialNumberOkView.isHidden = false
        }

        if !activationCodeOkay || !serialNumberOkay {
            showAlert(
                message: isArabicSelected ? "الرقم التسلسلي / رمز التفعيل غير صالحين." : "Serial/Activation number, both codes are invalid."
            )

            return "false"
        }
        // Get the values without spaces
        let serialNumber = serialNumberField.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let activationCode = activationCodeField.text?.replacingOccurrences(of: " ", with: "") ?? ""

        identity = ETIdentityProvider.generate(nil,
                                               serialNumber: serialNumber,
                                               activationCode: activationCode)

        // Show the registration code. In real life this code will have to somehow
        // be entered in to IdentityGuard to complete activation.
        registrationCodeField.text = identity?.registrationCode
        datasave()

        return registrationCodeField.text

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
                
                
                if let otp = currentOtp, otp.count >= 6 {
                    let x = otp.count / 2
                    let index = otp.index(otp.startIndex, offsetBy: x)
                    let formattedOtp = otp[..<index] + "-" + otp[index...]
                    otpLabel?.text = String(formattedOtp)
                }
                
                
//                otpLabel?.text = currentOtp
                otpCountdown?.progress = Float(1.0 - (timeSinceLastOtp / ET_OTP_VALIDITY_PERIOD))
            }
        }
        
        if currentOtp == nil {
            currentTimestamp = Date()
            currentOtp = identity?.getOTP(currentTimestamp)
//            otpLabel?.text = currentOtp
            
            if let otp = currentOtp, otp.count >= 6 {
                let x = otp.count / 2
                let index = otp.index(otp.startIndex, offsetBy: x)
                let formattedOtp = otp[..<index] + "-" + otp[index...]
                otpLabel?.text = String(formattedOtp)
            }
            
            otpCountdown?.progress = 1.0
            
            if let otp = currentOtp {
                defaults.set(otp, forKey: otpKey)
                defaults.set(currentTimestamp, forKey: timestampKey)
                defaults.synchronize()
            }
        }
        
        otpLabel?.isHidden = false
        otpCountdown?.isHidden = false
        
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




import Security

class EncryptionHelper {
    static let shared = EncryptionHelper()

    private let key: Data
    private let keychainKeyTag = "com.riyadbank.softtoken.encryptionkey"

    init() {
        // Load the AES key from the Keychain, or generate and persist a new
        // random one. The key is never derived from a fixed/hardcoded secret.
        if let savedKey = EncryptionHelper.loadFromKeychain(tag: keychainKeyTag) {
            self.key = savedKey
        } else {
            let newKey = EncryptionHelper.generateRandomData(length: 32) // 256-bit key
            self.key = newKey
            let status = EncryptionHelper.saveToKeychain(data: newKey, tag: keychainKeyTag)
            if status != errSecSuccess {
                // A failed persist must not crash the app: the in-memory key keeps
                // this session working, and the next launch generates a fresh key.
                NSLog("EncryptionHelper: failed to persist key to Keychain (OSStatus %d)", status)
            }
        }
    }

    // Generate random data
    private static func generateRandomData(length: Int) -> Data {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        // A CSPRNG failure has no safe fallback — encrypting with a predictable
        // key would be worse than stopping, so fail hard in all build configs.
        precondition(result == errSecSuccess, "SecRandomCopyBytes failed")
        return data
    }

    // Save to Keychain. Stored as a generic-password item: kSecClassKey expects
    // real key-object attributes and rejects raw bytes on some OS versions.
    @discardableResult
    private static func saveToKeychain(data: Data, tag: String) -> OSStatus {
        let baseQuery = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: tag,
            kSecAttrAccount: tag
        ] as [String: Any]

        SecItemDelete(baseQuery as CFDictionary) // Delete existing item

        var addQuery = baseQuery
        addQuery[kSecValueData as String] = data
        // Device-only, never migrated to backups or other devices.
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(addQuery as CFDictionary, nil)
    }

    // Load from Keychain
    private static func loadFromKeychain(tag: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: tag,
            kSecAttrAccount: tag,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        return (status == errSecSuccess) ? (item as? Data) : nil
    }

    // Encrypts `data` with a freshly generated random IV for every call, and
    // prepends that IV to the returned ciphertext. Reusing a single static IV
    // across many CBC encryptions (as this previously did) leaks information
    // about repeated plaintext blocks, so each message needs its own IV.
    func encrypt(_ data: Data) throws -> Data {
        let iv = EncryptionHelper.generateRandomData(length: kCCBlockSizeAES128) // 128-bit IV
        let cryptLength = data.count + kCCBlockSizeAES128
        var encryptedData = Data(count: cryptLength)

        var numBytesEncrypted: Int = 0
        let cryptStatus = encryptedData.withUnsafeMutableBytes { encryptedBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            encryptedBytes.baseAddress, cryptLength,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }

        guard cryptStatus == kCCSuccess else {
            throw EncryptionError.encryptionFailed
        }

        encryptedData.count = numBytesEncrypted
        return iv + encryptedData
    }

    // Reads the IV prepended by `encrypt(_:)` off the front of `data` before decrypting the remainder.
    func decrypt(_ data: Data) throws -> Data {
        guard data.count > kCCBlockSizeAES128 else {
            throw EncryptionError.decryptionFailed
        }
        let iv = data.prefix(kCCBlockSizeAES128)
        let ciphertext = data.suffix(from: data.startIndex + kCCBlockSizeAES128)

        let cryptLength = ciphertext.count + kCCBlockSizeAES128
        var decryptedData = Data(count: cryptLength)

        var numBytesDecrypted: Int = 0
        let cryptStatus = decryptedData.withUnsafeMutableBytes { decryptedBytes in
            ciphertext.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, ciphertext.count,
                            decryptedBytes.baseAddress, cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }

        guard cryptStatus == kCCSuccess else {
            throw EncryptionError.decryptionFailed
        }

        decryptedData.count = numBytesDecrypted
        return decryptedData
    }
}

enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
}

extension String {
    /// Convert base64 string to Data
    var fromBase64: Data? {
        return Data(base64Encoded: self)
    }

    /// Convert string to base64 string
    var toBase64: String {
        return self.data(using: .utf8)?.base64EncodedString() ?? ""
    }
}
