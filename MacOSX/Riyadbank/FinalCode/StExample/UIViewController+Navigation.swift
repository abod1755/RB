import UIKit

extension UIViewController {
    
    func setupNavigationBar(title: String) {
        self.title = title
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.isHidden = false
        
        var settingsIcon: UIImage?
        if #available(iOS 13.0, *) {
            settingsIcon = UIImage(systemName: "gearshape") // SF Symbol for iOS 13+
        } else {
            settingsIcon = UIImage(named: "custom_settings_icon") // Use a custom asset for iOS 12-
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: settingsIcon,
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
    }

    @objc func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
