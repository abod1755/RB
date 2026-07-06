import UIKit
import Darwin
import MachO

@_silgen_name("ptrace")
private func ptrace(_ request: Int32, _ pid: pid_t, _ addr: UnsafeMutableRawPointer?, _ data: Int32) -> Int32

@_silgen_name("sysctl")
private func sysctl(_ name: UnsafeMutablePointer<Int32>?, _ namelen: u_int, _ oldp: UnsafeMutableRawPointer?, _ oldlenp: UnsafeMutablePointer<Int>?, _ newp: UnsafeMutableRawPointer?, _ newlen: Int) -> Int32

// Custom UITabBar subclass that gives the icon+label stack a little extra height
// on compact-width phones, without manually moving the items (which caused the
// icon to overlap its title). UIKit lays out the icon and label itself.
class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        // The system height already accounts for the bottom safe-area inset, so we
        // only ever grow it — never shrink below it, which would cram the stack.
        let isSmallScreen = UIScreen.main.bounds.width <= 375
        if isSmallScreen {
            sizeThatFits.height = max(sizeThatFits.height, 82)
        }
        return sizeThatFits
    }
}

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var screenshotBlockView: UIView?
    private var inactivityTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Replace default tab bar with custom tab bar
        setValue(CustomTabBar(), forKey: "tabBar")
        
        // Check for debugger first
        if isDebuggerAttached() {
            showDebuggerAlert()
            return
        }
        
        // Check for jailbreak
        if isJailbroken() {
            showJailbreakAlert()
            return
        }
        
        navigationItem.hidesBackButton = true
        
        // Initial setup of view controllers with language-based titles
        setupViewControllers()
        
        // Apply layout direction based on language
        let isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        UIView.appearance().semanticContentAttribute = isArabicSelected ? .forceRightToLeft : .forceLeftToRight
        
        // Customize tab bar appearance
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white // Ensure white background
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            )
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            )
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            )]
            
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.barTintColor = .white // Ensure white background for older iOS
            tabBar.tintColor = UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            )
        }
        
        // Set delegate
        delegate = self
        
        // Add screenshot protection
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(preventScreenshot),
                                             name: UIApplication.userDidTakeScreenshotNotification,
                                             object: nil)
        
        // Prevent screen capture by securing the window
        secureWindow()
        
        // Start the inactivity timer
        startInactivityTimer()
    }
    
    // Override touches to reset timer
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        resetInactivityTimer()
    }
    
    // Start or restart the inactivity timer
    private func startInactivityTimer() {
        invalidateInactivityTimer() // Invalidate any existing timer
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: false) { [weak self] _ in
            self?.handleInactivityTimeout()
        }
    }
    
    private func resetInactivityTimer() {
        startInactivityTimer() // Restart the timer on user interaction
    }
    
    // Invalidate existing timer
    private func invalidateInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    // Handle timeout - show login screen and ensure logout
    private func handleInactivityTimeout() {
        // Invalidate the timer to prevent multiple triggers
        invalidateInactivityTimer()
        
        // Create the login view controller
        let loginVC = FourDigitViewController()
        loginVC.modalPresentationStyle = .fullScreen
        
        // Replace the root view controller with the login screen
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
    
    private func isDebuggerAttached() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            var debuggerIsAttached = false
            
            // Check sysctl for process info
            var info = kinfo_proc()
            var infoSize = MemoryLayout<kinfo_proc>.size
            var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
            let sysctlResult = sysctl(&mib, u_int(mib.count), &info, &infoSize, nil, 0)
            if sysctlResult == 0 {
                debuggerIsAttached = (info.kp_proc.p_flag & P_TRACED) != 0
            }
            
            // Define PT_DENY_ATTACH
            let PT_DENY_ATTACH: Int32 = 31
            // Attempt to deny debugger attachment
            let ptraceResult = ptrace(PT_DENY_ATTACH, 0, UnsafeMutableRawPointer(bitPattern: 0), 0)
            if ptraceResult != 0 {
                debuggerIsAttached = true
            }
            
            // Timing-based check for debugger
            let startTime = Date()
            for _ in 0..<1000 {
                _ = arc4random()
            }
            let timeElapsed = Date().timeIntervalSince(startTime)
            if timeElapsed > 0.01 {
                debuggerIsAttached = true
            }
            
            return debuggerIsAttached
        #endif
    }
    
    private func showDebuggerAlert() {
        let alert = UIAlertController(
            title: "Security Warning",
            message: "This app cannot run while being debugged for security reasons.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
            exit(0)
        })
        present(alert, animated: true)
    }
    


    private func isJailbroken() -> Bool {
            #if targetEnvironment(simulator)
                return false
            #else
                // Simplified file-based checks
                let jailbreakPaths = [
                    "/Applications/Cydia.app",
                    "/Library/MobileSubstrate/MobileSubstrate.dylib",
                    "/bin/bash",
                    "/usr/sbin/sshd",
                    "/etc/apt",
                    "/private/var/lib/apt/",
                    "/usr/bin/ssh",
                    "/usr/libexec/sftp-server",
                    "/Applications/Sileo.app",
                    "/var/jb",
                    "/usr/lib/libjailbreak.dylib",
                    "/Applications/Zebra.app",
                    "/private/var/mobile/Library/SBSettings",
                    "/Applications/blackra1n.app",
                    "/Applications/FakeCarrier.app",
                    "/Applications/Icy.app",
                    "/Applications/IntelliScreen.app",
                    "/Applications/MxTube.app",
                    "/Applications/RockApp.app",
                    "/Applications/SBSetttings.app",
                    "/Applications/WinterBoard.app",
                    "/bin/sh",
                    "/bin/su",
                    "/etc/ssh/sshd_config",
                    "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                    "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                    "/Library/MobileSubstrate/MobileSubstrate.dylib",
                    "/pguntether",
                    "/private/var/lib/cydia",
                    "/private/var/mobile/Library/SBSettings/Themes",
                    "/private/var/stash",
                    "/private/var/tmp/cydia.log",
                    "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                    "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                    "/usr/bin/cycript",
                    "/usr/bin/sshd",
                    "/usr/libexec/ssh-keysign",
                    "/usr/sbin/frida-server",
                    "/var/cache/apt",
                    "/var/lib/cydia",
                    "/var/log/syslog",
                    "/var/mobile/Media/.evasi0n7_installed",
                    "/var/tmp/cydia.log",
                    "/var/jb"
                ]
                for path in jailbreakPaths {
                    if FileManager.default.fileExists(atPath: path) {
                        return true
                    }
                }
                
                // Simplified sandbox integrity check
                let testPath = "/private/jailbreak_test.txt"
                do {
                    try "JailbreakTest".write(toFile: testPath, atomically: true, encoding: .utf8)
                    try FileManager.default.removeItem(atPath: testPath)
                    return true
                } catch {
                    // Expected failure on non-jailbroken devices
                }
                
                // Simplified URL scheme check
                if let url = URL(string: "cydia://"), UIApplication.shared.canOpenURL(url) {
                    return true
                }
                
                return false
            #endif
        }
    
    private func showJailbreakAlert() {
        let alert = UIAlertController(
            title: "Security Warning",
            message: "This app cannot run on a rooted device due to security restrictions.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
            exit(0)
        })
        present(alert, animated: true)
    }
    
    @objc private func preventScreenshot() {
        let blockView = UIView(frame: view.bounds)
        blockView.backgroundColor = .black
        view.addSubview(blockView)
        screenshotBlockView = blockView
        
        let alert = UIAlertController(title: "Restricted",
                                    message: "Screenshots are not allowed in this app.",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.screenshotBlockView?.removeFromSuperview()
            self?.screenshotBlockView = nil
        })
        present(alert, animated: true)
    }
    
    private func secureWindow() {
        if let window = UIApplication.shared.windows.first {
            let field = UITextField()
            field.isSecureTextEntry = true
            window.addSubview(field)
            field.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            window.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.last?.addSublayer(window.layer)
        }
    }
    
    private func setupViewControllers() {
        let isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        
        let homeVC = createHomeViewController(isArabic: isArabicSelected)
        let settingsVC = createSettingsViewController(isArabic: isArabicSelected)
        let infoVC = RiyadBankViewController()
        let helpVC = MoreViewController()
        
        let homeIcon = createIcon(systemName: "house.fill", fallbackName: "custom_home_icon")
        let settingsIcon = createIcon(systemName: "gearshape.fill", fallbackName: "custom_settings_icon")
        let infoIcon = createIcon(systemName: "info.circle.fill", fallbackName: "custom_info_icon")
        let helpIcon = createIcon(systemName: "questionmark.circle.fill", fallbackName: "custom_help_icon")
        
        homeVC.tabBarItem = UITabBarItem(title: isArabicSelected ? "الرئيسية" : "HOME", image: homeIcon, tag: 0)
        
        settingsVC.tabBarItem = UITabBarItem(title: isArabicSelected ? "الإعدادات" : "SETTINGS", image: settingsIcon, tag: 1)
        infoVC.tabBarItem = UITabBarItem(title: isArabicSelected ? "معلومات" : "INFO", image: infoIcon, tag: 2)
        helpVC.tabBarItem = UITabBarItem(title: isArabicSelected ? "مساعدة" : "HELP", image: helpIcon, tag: 3)
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        let infoNav = UINavigationController(rootViewController: infoVC)
        let helpNav = UINavigationController(rootViewController: helpVC)
        
        viewControllers = [homeNav, settingsNav, infoNav, helpNav]
    }
    
    private func createHomeViewController(isArabic: Bool) -> startViewController {
        let homeVC = startViewController()
        let homeIcon = createIcon(systemName: "house.fill", fallbackName: "custom_home_icon")
        homeVC.tabBarItem = UITabBarItem(title: isArabic ? "الرئيسية" : "HOME", image: homeIcon, tag: 0)
        return homeVC
    }
    
    private func createSettingsViewController(isArabic: Bool) -> SettingsViewController {
        let settingsVC = SettingsViewController()
        let settingsIcon = createIcon(systemName: "gear", fallbackName: "custom_settings_icon")
        settingsVC.tabBarItem = UITabBarItem(title: isArabic ? "الإعدادات" : "SETTINGS", image: settingsIcon, tag: 1)
        return settingsVC
    }
    
    private func createIcon(systemName: String, fallbackName: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: systemName)?.withTintColor(UIColor(
                red: 0/255,
                green: 175/255,
                blue: 154/255,
                alpha: 1.0
            ), renderingMode: .alwaysOriginal)
        } else {
            return UIImage(named: fallbackName)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                name: UIApplication.userDidTakeScreenshotNotification,
                                                object: nil)
        invalidateInactivityTimer()
    }
}

extension MainTabBarController {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let isArabicSelected = UserDefaults.standard.bool(forKey: "isArabicSelected")
        
        if let navController = viewController as? UINavigationController {
            if navController.tabBarItem.tag == 0 {
                let freshHomeVC = createHomeViewController(isArabic: isArabicSelected)
                navController.setViewControllers([freshHomeVC], animated: false)
            }
            else if navController.tabBarItem.tag == 1 {
                if !(navController.topViewController is SettingsViewController) {
                    let freshSettingsVC = createSettingsViewController(isArabic: isArabicSelected)
                    navController.setViewControllers([freshSettingsVC], animated: false)
                }
            }
            else if navController.tabBarItem.tag == 2 {
                if !(navController.topViewController is RiyadBankViewController) {
                    let infoVC = RiyadBankViewController()
                    infoVC.title = isArabicSelected ? "معلومات" : ""
                    let infoIcon = createIcon(systemName: "info.circle.fill", fallbackName: "custom_info_icon")
                    infoVC.tabBarItem = UITabBarItem(title: isArabicSelected ? "معلومات" : "INFO", image: infoIcon, tag: 2)
                    navController.setViewControllers([infoVC], animated: false)
                }
            }
            else if let helpVC = navController.topViewController as? MoreViewController {
                helpVC.handleMoreAction()
            }
        }
        resetInactivityTimer() // Reset timer when switching tabs
    }
}



//
