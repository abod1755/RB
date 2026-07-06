import UIKit

class MoreViewController: UIViewController {
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
//        title = "More Options"
        
        // Customize the navigation bar
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 34/255, green: 1/255, blue: 74/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // Add UI elements
        setupUI()
    }
    
    private func setupUI() {
        // Create a white container view
        
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0) // Dark blue approximating #1E2A44
        
        // Bank image view
        let bankImageView = UIImageView(image: UIImage(named: "bank_log.png"))
        bankImageView.contentMode = .scaleAspectFit
        bankImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bankImageView)
        
        // White background view
        let whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = UIColor.white
        whiteBackgroundView.layer.cornerRadius = 10
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(whiteBackgroundView)
        
        // Stack view for content
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.addSubview(stackView)
        
        let nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: "RBType-RB-Bold", size: 20)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0
        nameLabel.text = isArabicSelected ? "المزيد من الخيارات" : "More Option"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let helpButton = UIButton(type: .system)
        helpButton.setTitle(isArabicSelected ? "مساعدة" : "HELP", for: .normal)
        helpButton.setTitleColor(.white, for: .normal)
        helpButton.backgroundColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        )
        helpButton.layer.cornerRadius = 5
//        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        helpButton.titleLabel?.font = UIFont(name: "RBType-RB-Bold", size: 16)
        helpButton.contentHorizontalAlignment = isArabicSelected ? .right : .left
        helpButton.titleEdgeInsets = isArabicSelected ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20) : UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.addTarget(self, action: #selector(handleHelpAction), for: .touchUpInside)


        // Create a chevron label
        let helpchevronLabel = UILabel()
        helpchevronLabel.text = "▶"
        helpchevronLabel.textColor = .white
        helpchevronLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        helpchevronLabel.translatesAutoresizingMaskIntoConstraints = false
        helpButton.addSubview(helpchevronLabel)
        
        stackView.addArrangedSubview(helpButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 200),
            
            
            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 10),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            // Remove fixed height to allow dynamic sizing based on content
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            
            
            helpButton.heightAnchor.constraint(equalToConstant: 40),
            helpchevronLabel.centerYAnchor.constraint(equalTo: helpButton.centerYAnchor),
            helpchevronLabel.trailingAnchor.constraint(equalTo: helpButton.trailingAnchor, constant: -15),

            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20)
        ])
        
        // Add actions for buttons
//        helpButton.addTarget(self, action: #selector(handleHelpAction), for: .touchUpInside)
    }
    
    // Action for "HELP" button
    @objc private func handleHelpAction() {
        let callUsVC = HelpUsViewController()
        navigationController?.pushViewController(callUsVC, animated: true)
    }
    
    // Action for "More" (added to fix the issue)
    @objc func handleMoreAction() {
        print("")
        // Add your custom logic here if needed (e.g., navigate to another screen or perform an action)
    }
}
