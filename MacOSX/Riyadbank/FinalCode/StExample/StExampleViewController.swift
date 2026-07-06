//
//  ViewController.swift
//  StExample
//
//  Created by Suman Naskar on 04/12/23.
//

import UIKit
import EntrustIGMobile

class StExampleViewController: UIViewController {

    @IBOutlet weak var serialNumberField: UITextField!
    @IBOutlet weak var activationCodeField: UITextField!
    @IBOutlet weak var registrationCodeField: UITextField!
    @IBOutlet weak var serialNumberOkView: UIImageView!
    @IBOutlet weak var activationCodeOkView: UIImageView!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var currentOtp: UILabel!
    @IBOutlet weak var otpCountdown: UIProgressView!
    @IBOutlet weak var version: UILabel!

    // Variables related to the identity and OTP generation.

    private var identity: ETIdentity?
    private var countdownTimer: Timer?
    private var lastOtpUpdate: Date?

    override func viewDidLoad() {
        

        self.serialNumberOkView.isHidden = true
        self.activationCodeOkView.isHidden = true
        self.otpLabel.isHidden = true
        self.currentOtp.isHidden = true
        self.otpCountdown.isHidden = true

        ETSoftTokenSDK.setLogLevel(ETLogLevelOff)
        ETSoftTokenSDK.initializeSDK()

        self.setSDKVersion()

        super.viewDidLoad()
    }

    /**
     Display SDK version in the app retrieving it from the SDK.
     */

    private func setSDKVersion() {
        if let fullVersion = ETSoftTokenSDK.getVersion() {
            self.version.text = "SDK version: \(fullVersion)"
        }
    }

    // MARK: - Handle codes being set to valid/invalid options.

    /**
     Check the entered codes. If valid, show an OTP. If they're not valid,
     hide UI elements as appropriate.
     */

    private func checkCodes() {

        // See if activation code is valid

        var activationCodeOkay = false

        do {
            
            if activationCodeField.text!.count == 0 {
                // NSException(name: NSExceptionName(rawValue: "Invalid activation code") ?? "0", reason: "Empty activation code")
            } else {
                try ETIdentityProvider.validateActivationCode(activationCodeField.text)
                activationCodeOkay = true
            }
        } catch let error {
            activationCodeOkay = false
            activationCodeOkView.isHidden = true
            self.invalidCodes()
        }

        // Hide the keyboard if required, and show the "activation code is valid" image
        if activationCodeOkay {
            activationCodeField.resignFirstResponder()
            activationCodeOkView.isHidden = false
        }

        // check serial number

        var serialNumberOkay = false
        do {
            // NSError *error = nil;
            // [ETIdentityProvider validateSerialNumber:serialNumberField.text];
            try  ETIdentityProvider.validateSerialNumber(serialNumberField.text)
            serialNumberOkay = true

        } catch let error {
            // Serial number is not valid.
            serialNumberOkView.isHidden = true
            self.invalidCodes()
        }
        if serialNumberOkay {
            // If we get here then the string is valid.
            // Hide the keyboard if required, and show the "serial number is valid" image
            self.serialNumberField.resignFirstResponder()
            self.serialNumberOkView.isHidden = false
        }

        if !activationCodeOkay || !serialNumberOkay {
            return
        }

        identity = ETIdentityProvider.generate(nil,
                                               serialNumber: serialNumberField.text,
                                               activationCode: activationCodeField.text)

        // Show the registration code. In real life this code will have to somehow
        // be entered in to IdentityGuard to complete activation.
        registrationCodeField.text = identity?.registrationCode

        // Get the current OTP, show it, and start the timer to count down to the next OTP.
        lastOtpUpdate = Date()
        currentOtp.text = identity?.getOTP(lastOtpUpdate)
        otpLabel.isHidden = false
        currentOtp.isHidden = false
        otpCountdown.isHidden = false
        otpCountdown.progress = 1.0
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                              target: self,
                                              selector: #selector(updateCountdownProgress(sender:)),
                                              userInfo: nil, repeats: true)

        // Both codes are valid at this point. Create a new identity.

    }

    /**
     Common cleanup when either the serial number or activation code are invalid.
     */

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

        self.otpLabel.isHidden = true
        self.currentOtp.isHidden = true
        self.otpCountdown.isHidden = true
        self.registrationCodeField.text = ""
    }

    // MARK: Timer callbacks

    @objc func updateCountdownProgress(sender: Timer) {

        if let lastOtpUpdate = lastOtpUpdate {
            let timeSinceLastOtp = -lastOtpUpdate.timeIntervalSinceNow

            // We calculate the progress as counting down from 100%

            let progress: Float = Float(1.0 - (timeSinceLastOtp / ET_OTP_VALIDITY_PERIOD))

            if progress <= 0.0 {
                // Time for a new OTP
                self.lastOtpUpdate = Date()
                currentOtp.text = identity?.getOTP(lastOtpUpdate)
                otpCountdown.progress = 1.0
            } else {
                // Current OTP is still OK, update the progress.
                otpCountdown.progress = progress
            }

        }

    }

}
extension StExampleViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func handleTextFieldValueChanged(_ sender: UITextField) {

        guard let text = sender.text else {
            return
        }
        

        for char in text {

            // Only digits and the '-' character are valid.
            // This is a bit awkward in the UI, as the user can try to type unacceptable characters.
            // A more involved solution would be to automatically insert the '-' characters and
            // only show the number pad keyboard.

            if !("0" <= char && char <= "9") && char != "-" {
                return
            }

            if (text.count >= 10 && !text.contains("-")) || text.count >= 11 {
                self.checkCodes()
            }
        }
    }

}
