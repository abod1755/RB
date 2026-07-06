import UIKit

class RIYADTOKENUseViewController: UIViewController {
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
        nameLabel.font = UIFont(name: "RBType-RB-Regular", size: 16)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 0

        let instructionText = isArabicSelected ? """
        لتسجيل الدخول إلى حسابك في البنك الرياض مصرفية الإنترنت أو البنك الرياض مصرفية الجوال باستخدام برنامج رمز التفعيل "البنك" الرياض توكن"، اتبع الخطوات التالية:

        قم بإدخال اسم المستخدم والرمز السري الخاص بك في خانة تسجيل الدخول ثم انقر على "تسجيل الدخول".
        سيطلب منك اختيار طريقة التحقق التي ترغب في استخدامها لتسجيل الدخول، اختر "تعميد عن طريق برنامج أو جهاز رمز التفعيل (البنك الرياض توكن)".
        قم بتشغيل برنامج رمز التفعيل وادخل الرمز الظاهر على شاشة جوالك في الخانة المخصصة بالبنك الرياض مصرفية الانترنت ثم انقر على "موافق" لإتمام تسجيل الدخول.
        """ : """
        To login to your account through Riyad Internet Banking or RiyadMobile using RiyadToken, follow these steps:
        1. Enter your username and password in the login field then click 'Log in'.
        2. You will be requested to select an authentication method for your login, choose 'Authenticate via RiyadToken'.
        3. Open the Soft Token application and enter the displayed security code into the activation code field in Riyad Internet Banking or RiyadMobile screen then click 'OK' to complete the process.
        """

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // Adjust for desired spacing
        paragraphStyle.alignment = isArabicSelected ? .right : .left // Ensure alignment
        paragraphStyle.baseWritingDirection = isArabicSelected ? .rightToLeft : .leftToRight // Set RTL for Arabic
        let attributedString = NSAttributedString(
            string: instructionText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        )
        nameLabel.attributedText = attributedString
        nameLabel.semanticContentAttribute = isArabicSelected ? .forceRightToLeft : .forceLeftToRight // Force RTL for Arabic
        
        stackView.addArrangedSubview(nameLabel)
 // Add label to stack view
        
        // Constraints
        NSLayoutConstraint.activate([
            // Bank image view constraints
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 300),
            bankImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // White background view constraints
            whiteBackgroundView.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 10),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            // Remove fixed height to allow dynamic sizing based on content
            whiteBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            // Stack view constraints
            stackView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -20) // Adjusted to fit content
        ])
    }
}
