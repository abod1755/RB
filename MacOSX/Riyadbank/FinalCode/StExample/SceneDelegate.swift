import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Ensure the scene is a UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create a new UIWindow with the windowScene
        let window = UIWindow(windowScene: windowScene)
        
        // Set FourDigitViewController as the root view controller
        let loginVC = FourDigitViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navController
        
        // Assign the window to the property and make it visible
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Always show login screen when entering foreground
        if let window = window {
            let loginVC = FourDigitViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navController
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // No need to track background time since login is shown every time
    }
}
