import UIKit

extension UIViewController {

    func setupBottomNavbar() {
        let bottomToolbar = UIToolbar()
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)

        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(openSettings))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        bottomToolbar.items = [homeButton, flexibleSpace, settingsButton]

        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func homeButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}
