import UIKit

class RIYADTOKENReinitializepinViewController: UIViewController {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        setupUI()
        navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
        // Set background color
//        view.backgroundColor = UIColor(red: 30/255, green: 42/255, blue: 68/255, alpha: 1.0) // Dark blue approximating #1E2A44
        view.backgroundColor = UIColor(
            red: 35/255.0,
            green: 8/255.0,
            blue: 113/255.0,
            alpha: 1.0
        )
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
        
        // Instruction label
        let nameLabel = UILabel()
        nameLabel.textAlignment = isArabicSelected ? .right : .left
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0

        nameLabel.text = isArabicSelected ? """
        1. في شاشة إلغاء القفل، حدد إعادة التهيئة.
        2. ستؤدي إعادة تهيئة التطبيق إلى مسح رمز التوكن المسجل.
        3. أضف رمز توكن جديد من خلال العملية العادية.
        """ : """
        1. In the unlock screen, select re-initialize.
        2. Re-initializing the app will erase the registered soft token.
        3. Add a new soft token through the normal process.
        """

        stackView.addArrangedSubview(nameLabel)

        
        // Constraints
        NSLayoutConstraint.activate([
            // Bank image view constraints
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 160),
            
            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 20),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Remove fixed height to allow dynamic sizing based on content
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20) // Adjusted to fit content
        ])
    }
}
