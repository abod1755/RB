import UIKit
import EntrustIGMobile
import Foundation
import CommonCrypto
import Security

class startViewController: UIViewController {
    var tokenLabel: UILabel!
    private var addTokenButton: UIButton!
    private var whiteBackgroundView: UIView! // Declared as a class property
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
        // Set the background color of the main view
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
    
        // Initialize SDK and set log level
        ETSoftTokenSDK.setLogLevel(ETLogLevelOff)
        ETSoftTokenSDK.initializeSDK()
    
        // Create a white background view
        whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 10
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackgroundView)
        
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
    
        // Create logo image view
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        if let logoImage = UIImage(named: "entrust.png") {
            logoImageView.image = logoImage
        }
        logoImageView.contentMode = .scaleAspectFit
        whiteBackgroundView.addSubview(logoImageView)
    
        // Create token label (inside whiteBackgroundView)
        tokenLabel = UILabel()
        tokenLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenLabel.text = isArabicSelected ? " اضافۃ رمز جدید " : "Set New Soft Token"
        tokenLabel.textAlignment = .center
        tokenLabel.textColor = .black
        tokenLabel.font = UIFont(name: "RBType-RB-Bold", size: 24)
        whiteBackgroundView.addSubview(tokenLabel)
    
        // Create "START HERE" Button
        addTokenButton = UIButton(type: .system)
        addTokenButton.setTitle(isArabicSelected ? "ابدأ هنا" : "START HERE", for: .normal)
        addTokenButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        addTokenButton.setTitleColor(.white, for: .normal)
        addTokenButton.layer.cornerRadius = 6
        addTokenButton.titleLabel?.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 16)
//        addTokenButton.titleLabel?.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 16)
        addTokenButton.addTarget(self, action: #selector(addTokenButtonTapped), for: .touchUpInside)
        addTokenButton.translatesAutoresizingMaskIntoConstraints = false
        addTokenButton.tag = 999
        whiteBackgroundView.addSubview(addTokenButton)
    
        // Set up constraints
        NSLayoutConstraint.activate([
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            bankImageView.heightAnchor.constraint(equalTo: bankImageView.widthAnchor, multiplier: 0.533),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 30),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            whiteBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            whiteBackgroundView.heightAnchor.constraint(equalToConstant: 250),
            
            
            
    
            logoImageView.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
    
            tokenLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            tokenLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
    
            addTokenButton.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 20),
            addTokenButton.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            addTokenButton.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            addTokenButton.heightAnchor.constraint(equalToConstant: 44),
            addTokenButton.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -16)
        ])
    
        showSavedTokens(on: view)
    }

    private func showSavedTokens(on containerView: UIView) {
        // Remove any previous subviews added by this method to avoid duplicates
        containerView.subviews.filter { $0.tag == 998 }.forEach { $0.removeFromSuperview() }
    
        // Create ScrollView for token buttons
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.tag = 998
        scrollView.showsVerticalScrollIndicator = true
        containerView.addSubview(scrollView)
    
        // Create StackView for token buttons inside ScrollView
        let tokenStackView = UIStackView()
        tokenStackView.axis = .vertical
        tokenStackView.spacing = 10
        tokenStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tokenStackView)
    
        // Set up constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            scrollView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
    
            tokenStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            tokenStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tokenStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tokenStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            tokenStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    
        // Load saved tokens
        let defaults = UserDefaults.standard
        var savedTokens: [[String: String]] = []
    
        if let encryptedData = defaults.object(forKey: "savedTokens") as? Data {
            do {
                let decryptedData = try EncryptionHelper.shared.decrypt(encryptedData)
                savedTokens = try JSONSerialization.jsonObject(with: decryptedData, options: []) as? [[String: String]] ?? []
            } catch {
                print("")
            }
        } else {
            savedTokens = defaults.array(forKey: "savedTokens") as? [[String: String]] ?? []
        }
    
        if savedTokens.isEmpty {
            let noTokenLabel = UILabel()
            noTokenLabel.text = ""
            noTokenLabel.textAlignment = .center
            noTokenLabel.textColor = .white
            noTokenLabel.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) : UIFont.boldSystemFont(ofSize: 16)
            noTokenLabel.translatesAutoresizingMaskIntoConstraints = false
            tokenStackView.addArrangedSubview(noTokenLabel)
    
            NSLayoutConstraint.activate([
                noTokenLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            for token in savedTokens {
                if let tokenName = token["tokenName"] {
                    // Create a container view for token button and circle
                    let tokenContainer = UIStackView()
                    tokenContainer.axis = .horizontal
                    tokenContainer.spacing = 10
                    tokenContainer.alignment = .center
                    tokenContainer.translatesAutoresizingMaskIntoConstraints = false

                    // Create the button
                    let tokenButton = UIButton(type: .system)
                    tokenButton.setTitle(tokenName, for: .normal)
                    tokenButton.setTitleColor(.black, for: .normal) // Set text color to black
                    tokenButton.backgroundColor = .white
                    tokenButton.layer.cornerRadius = 5
                    tokenButton.titleLabel?.font = isArabicSelected ? UIFont(name: "RBType-RB-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 18, weight: .bold) // Set bold font
                    tokenButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
                    // Adjust title insets to add space after the chevron
                    tokenButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: isArabicSelected ? 0 : 30, bottom: 0, right: isArabicSelected ? 30 : 0)
                    tokenButton.translatesAutoresizingMaskIntoConstraints = false
                    tokenButton.addTarget(self, action: #selector(tokenButtonTapped(_:)), for: .touchUpInside)
                    tokenContainer.addArrangedSubview(tokenButton)
                    tokenStackView.addArrangedSubview(tokenContainer)

                    // Add constraints
                    NSLayoutConstraint.activate([
                        tokenButton.heightAnchor.constraint(equalToConstant: 40),
                        tokenButton.widthAnchor.constraint(equalTo: tokenContainer.widthAnchor) // Full width
                    ])

                    // Create a chevron label
                    let chevronLabel = UILabel()
                    chevronLabel.text = "▶"
                    chevronLabel.textColor = UIColor(
                        red: 0/255,
                        green: 175/255,
                        blue: 154/255,
                        alpha: 1.0
                    )
                    chevronLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                    chevronLabel.translatesAutoresizingMaskIntoConstraints = false
                    tokenButton.addSubview(chevronLabel)
                    
                    // Add constraints for the chevron at the start
                    NSLayoutConstraint.activate([
                        chevronLabel.centerYAnchor.constraint(equalTo: tokenButton.centerYAnchor),
                        chevronLabel.leadingAnchor.constraint(equalTo: tokenButton.leadingAnchor, constant: 10) // Chevron at the start with padding
                    ])
                }
            }
        }
    
        // Force layout update to calculate the correct content size
        containerView.layoutIfNeeded()
    
        // Adjust the scrollView's contentSize based on the stackView's height
        scrollView.contentSize = CGSize(
            width: tokenStackView.frame.width,
            height: tokenStackView.frame.height
        )
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
            
            let tokenListVC = TokenListViewController(
                tokenName: selectedTokenName,
                serialNumber: serialNumber,
                activationCode: activationCode,
                savedOTP: savedOTP
            )
            
            navigationController?.pushViewController(tokenListVC, animated: true)
        }
    }
    
    @objc private func addTokenButtonTapped() {
        let newTokenVC = NewSoftTokenViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
}
