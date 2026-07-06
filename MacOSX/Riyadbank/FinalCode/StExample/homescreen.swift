import UIKit

class homescreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()



        var settingsIcon: UIImage?
        
        if #available(iOS 13.0, *) {
            settingsIcon = UIImage(systemName: "gearshape") // SF Symbol for iOS 13+
        } else {
            settingsIcon = UIImage(named: "custom_settings_icon") // Use a custom asset for iOS 12-
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(settingsTapped))
        
        // Create and configure the label
        let label = UILabel()
        label.text = "Hello, World!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Create and configure the button
        let button = UIButton(type: .system)
        button.setTitle("Tap Me", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }

    @objc func buttonTapped() {

        // Get the main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Instantiate StExampleViewController using its Storyboard ID
        if let stExampleVC = storyboard.instantiateViewController(withIdentifier: "StExampleViewController") as? StExampleViewController {
            
            // Create a Navigation Controller with StExampleViewController as root
            let navController = UINavigationController(rootViewController: stExampleVC)

            // Create an instance of MainTabBarController
            let tabBarVC = MainTabBarController()
            tabBarVC.modalPresentationStyle = .fullScreen

            // Set the Navigation Controller inside the Tab Bar
            tabBarVC.viewControllers = [navController]  // Set navController as first tab

            // Present the Tab Bar Controller
            present(tabBarVC, animated: true, completion: nil)
        }
    }





    @objc func settingsTapped() {
        print("")
    }
}
