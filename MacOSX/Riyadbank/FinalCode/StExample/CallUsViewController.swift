import UIKit

class CallUsViewController: UIViewController {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        
        // Set up the view with a dark purple background
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        navigationItem.hidesBackButton = true
        
        // Customize the navigation bar
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 34/255, green: 1/255, blue: 74/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // Add UI elements
        setupUI()
    }
    
    private func setupUI() {
        // Create a stack view to hold the buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Add bank logo image
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        // Create buttons with labels and circular icons
        let phoneBankingButton = createContactButton(
            title: isArabicSelected ? "هاتف البنك:\n800 124 3000" : "Phone Banking:\n800 124 3000",
            icon: "📞"
        )

        let vipPhoneBankingButton = createContactButton(
            title: isArabicSelected ? "هاتف كبار الشخصيات:\n800 124 3331" : "VIP Phone Banking:\n800 124 3331",
            icon: "📞"
        )

        let emailButton = createContactButton(
            title: isArabicSelected ? "راسلنا عبر البريد الإلكتروني:\nbtsecurity@riyadbank.com" : "Email Us:\nbtsecurity@riyadbank.com",
            icon: "✉️"
        )
        
        // Add buttons to stack view
        stackView.addArrangedSubview(phoneBankingButton)
        stackView.addArrangedSubview(vipPhoneBankingButton)
        stackView.addArrangedSubview(emailButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 150),
            
            phoneBankingButton.heightAnchor.constraint(equalToConstant: 70), // Increased height for consistency
            vipPhoneBankingButton.heightAnchor.constraint(equalToConstant: 70),
            emailButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Add actions (open phone or email app)
        phoneBankingButton.addTarget(self, action: #selector(handlePhoneBanking), for: .touchUpInside)
        vipPhoneBankingButton.addTarget(self, action: #selector(handleVIPPhoneBanking), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(handleEmail), for: .touchUpInside)
    }
    
    private func createContactButton(title: String, icon: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Set button title with newline
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.contentHorizontalAlignment = isArabicSelected ? .right : .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
        button.titleLabel?.numberOfLines = 0 // Allow multiple lines
        button.titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical) // Prevent vertical stretching
        
        // Create circular icon view
        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = .white
        iconView.layer.cornerRadius = 12
        button.addSubview(iconView)
        
        // Add icon label inside the circular view
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.textColor = .black
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.textAlignment = .center
        iconLabel.font = UIFont.systemFont(ofSize: 14)
        iconView.addSubview(iconLabel)
        
        // Add constraints for icon view and label
        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            iconView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalTo: iconView.widthAnchor),
            iconLabel.heightAnchor.constraint(equalTo: iconView.heightAnchor)
        ])
        
        return button
    }
    
    @objc private func handlePhoneBanking() {
        if let url = URL(string: "tel://8001243000"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func handleVIPPhoneBanking() {
        if let url = URL(string: "tel://8001243331"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func handleEmail() {
        if let url = URL(string: "mailto:btsecurity@riyadbank.com"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
