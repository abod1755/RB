import UIKit

class HelpUsViewController: UIViewController {
    private var isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
    private let email = "btsecurity@riyadbank.com"
    private let phone = "+966112046600"
    private var linkRanges: [(range: NSRange, url: URL)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        setupUI()
        navigationItem.hidesBackButton = true
    }
    
    private func setupUI() {
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
        
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.isUserInteractionEnabled = true
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        // Set text alignment based on language
        messageLabel.textAlignment = isArabicSelected ? .right : .left
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = isArabicSelected ? .right : .left
        paragraphStyle.lineSpacing = 6
        
        let messageText = isArabicSelected ? """
            عزيزي العميل،\n
             في حال وجود أي مشكلة في تطبيق التوكن، نرحب بالاتصال بنا:  \n
            \(email)\n
            +966-11-204-6600  تحويلة: 5161\n
            
            شكرا خدمات تقنية الأعمال.عمليات\n
            الأَمْنُ.
            """ : """
            Dear Colleague,\n
            If you are facing any issues with your Token, feel free to contact us:\n
            \(email)\n
            +966-11-204-6600  Ext: 5161\n
            Warm Regards\n
            BT Service Operations Section.
            Security Operations.
            """
        
        let attributedString = NSMutableAttributedString(
            string: messageText,
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        let linkColor = UIColor(
            red: 0/255,
            green: 175/255,
            blue: 154/255,
            alpha: 1.0
        ) // #007f7f
        
        // Clear previous link ranges
        linkRanges.removeAll()
        
        // Apply custom color to email and store its range
        if let emailRange = messageText.range(of: email) {
            let nsRange = NSRange(emailRange, in: messageText)
            attributedString.addAttribute(.foregroundColor, value: linkColor, range: nsRange)
            linkRanges.append((range: nsRange, url: URL(string: "mailto:\(email)")!))
        }
        
        // Apply custom color to phone number and store its range
        let phoneDisplayText = isArabicSelected ? "+966-11-204-6600  داخلي: 5161" : "+966-11-204-6600  Ext: 5161"
        if let phoneRange = messageText.range(of: phoneDisplayText) {
            let nsRange = NSRange(phoneRange, in: messageText)
            attributedString.addAttribute(.foregroundColor, value: linkColor, range: nsRange)
            linkRanges.append((range: nsRange, url: URL(string: "tel:\(phone)")!))
        }
        
        // Bold styling for "Dear Colleague" or Arabic equivalent
        if let dearColleagueRange = messageText.range(of: isArabicSelected ? "الزميل العزيز،" : "Dear Colleague,") {
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 16, weight: .bold),
                range: NSRange(dearColleagueRange, in: messageText)
            )
        }
        
        // Bold styling for "Warm Regards" or Arabic equivalent
        if let regardsRange = messageText.range(of: isArabicSelected ? "أطيب التحيات" : "Warm Regards") {
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 16, weight: .bold),
                range: NSRange(regardsRange, in: messageText)
            )
        }
        
        messageLabel.attributedText = attributedString
        
        // Add single tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        messageLabel.addGestureRecognizer(tap)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            bankImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            bankImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bankImageView.widthAnchor.constraint(equalToConstant: 180),
            bankImageView.heightAnchor.constraint(equalToConstant: 80),
            
            messageLabel.topAnchor.constraint(equalTo: bankImageView.bottomAnchor, constant: 15),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let attributedText = label.attributedText else { return }
        
        let location = sender.location(in: label)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Check if the tapped index falls within any link range
        for link in linkRanges {
            if NSLocationInRange(index, link.range) {
                UIApplication.shared.open(link.url, options: [:], completionHandler: nil)
                break
            }
        }
    }
}
