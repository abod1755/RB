import UIKit

class RiyadBankViewController: UIViewController {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        setupUI()
    }
    
    private func setupUI() {
        // Set background color
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0)
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
        
        // Bank logo image view
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        // White background view
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 8
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackgroundView)
        
        // Stack view for buttons
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.addSubview(stackView)
        
        // Button 1: RIYADTOKEN
        let RIYADTOKENButton = UIButton(type: .system)
        let buttonTitle = isArabicSelected ? "كيف استخدم البنك الرياض توكن" : "HOW CAN I USE RIYADTOKEN?"

        RIYADTOKENButton.setTitle(buttonTitle, for: .normal)
        RIYADTOKENButton.setTitleColor(.white, for: .normal)
        RIYADTOKENButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        RIYADTOKENButton.layer.cornerRadius = 5
        RIYADTOKENButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 16)
        RIYADTOKENButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        RIYADTOKENButton.titleEdgeInsets = isArabicSelected ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20) : UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        RIYADTOKENButton.translatesAutoresizingMaskIntoConstraints = false
        RIYADTOKENButton.addTarget(self, action: #selector(tokenButtonTapped(_:)), for: .touchUpInside)

        
        let RIYADTOKENchevronLabel = UILabel()
        RIYADTOKENchevronLabel.text = "▶"
        RIYADTOKENchevronLabel.textColor = .white
        RIYADTOKENchevronLabel.font = UIFont.systemFont(ofSize: 20)
        RIYADTOKENchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        RIYADTOKENButton.addSubview(RIYADTOKENchevronLabel)
        
        // Button 2: PIN
        let pinTOKENButton = UIButton(type: .system)
        pinTOKENButton.setTitle(isArabicSelected ? "ما هو رقم التعريف الشخصي (الرمز السري)" : "WHAT IS A PIN?", for: .normal)
        pinTOKENButton.setTitleColor(.white, for: .normal)
        pinTOKENButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        pinTOKENButton.layer.cornerRadius = 5
        pinTOKENButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 16)
        pinTOKENButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        pinTOKENButton.titleEdgeInsets = isArabicSelected
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            : UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        pinTOKENButton.translatesAutoresizingMaskIntoConstraints = false
        pinTOKENButton.addTarget(self, action: #selector(tokenButtonTappedusepin(_:)), for: .touchUpInside)

        
        let pinTOKENchevronLabel = UILabel()
        pinTOKENchevronLabel.text = "▶"
        pinTOKENchevronLabel.textColor = .white
        pinTOKENchevronLabel.font = UIFont.systemFont(ofSize: 20)
        pinTOKENchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        pinTOKENButton.addSubview(pinTOKENchevronLabel)
        
        // Button 3: Change PIN
        let changepinTOKENButton = UIButton(type: .system)
        changepinTOKENButton.setTitle(isArabicSelected ? "تغيير الرمز السري الخاص بك" : "CHANGE YOUR PIN?", for: .normal)
        changepinTOKENButton.setTitleColor(.white, for: .normal)
        changepinTOKENButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        changepinTOKENButton.layer.cornerRadius = 5
        changepinTOKENButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 16)
        changepinTOKENButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        changepinTOKENButton.titleEdgeInsets = isArabicSelected
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            : UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        changepinTOKENButton.translatesAutoresizingMaskIntoConstraints = false
        changepinTOKENButton.addTarget(self, action: #selector(tokenButtonTappedchangepin(_:)), for: .touchUpInside)

        
        let changepinTOKENchevronLabel = UILabel()
        changepinTOKENchevronLabel.text = "▶"
        changepinTOKENchevronLabel.textColor = .white
        changepinTOKENchevronLabel.font = UIFont.systemFont(ofSize: 20)
        changepinTOKENchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        changepinTOKENButton.addSubview(changepinTOKENchevronLabel)
        
        // Add buttons to stack view
        stackView.addArrangedSubview(RIYADTOKENButton)
        stackView.addArrangedSubview(pinTOKENButton)
        stackView.addArrangedSubview(changepinTOKENButton)
        
        // Updated constraints with relative sizing
        NSLayoutConstraint.activate([
            // Bank image view constraints
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -25),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            bankImageView.heightAnchor.constraint(equalTo: bankImageView.widthAnchor, multiplier: 0.533),

            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 25),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),

            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: whiteBackgroundView.bottomAnchor, constant: -15),

            // Button constraints
            RIYADTOKENButton.heightAnchor.constraint(equalToConstant: 45),
            RIYADTOKENchevronLabel.centerYAnchor.constraint(equalTo: RIYADTOKENButton.centerYAnchor),
            RIYADTOKENchevronLabel.trailingAnchor.constraint(equalTo: RIYADTOKENButton.trailingAnchor, constant: -10),

            pinTOKENButton.heightAnchor.constraint(equalToConstant: 45),
            pinTOKENchevronLabel.centerYAnchor.constraint(equalTo: pinTOKENButton.centerYAnchor),
            pinTOKENchevronLabel.trailingAnchor.constraint(equalTo: pinTOKENButton.trailingAnchor, constant: -10),

            changepinTOKENButton.heightAnchor.constraint(equalToConstant: 45),
            changepinTOKENchevronLabel.centerYAnchor.constraint(equalTo: changepinTOKENButton.centerYAnchor),
            changepinTOKENchevronLabel.trailingAnchor.constraint(equalTo: changepinTOKENButton.trailingAnchor, constant: -10),
        ])
    }
    
    // Button action methods
    @objc private func tokenButtonTapped(_ sender: UIButton) {
        let newTokenVC = RIYADTOKENUseViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
    
    @objc private func tokenButtonTappedusepin(_ sender: UIButton) {
        let newTokenVC = RIYADTOKENUsepinViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
    
    @objc private func tokenButtonTappedchangepin(_ sender: UIButton) {
        let newTokenVC = RIYADTOKENChangepinViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
    
    @objc private func tokenButtonTappedforgetpin(_ sender: UIButton) {
        let newTokenVC = RIYADTOKENForgetpinViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
    
    @objc private func tokenButtonTappedReinitializepin(_ sender: UIButton) {
        let newTokenVC = RIYADTOKENReinitializepinViewController()
        navigationController?.pushViewController(newTokenVC, animated: true)
    }
}
