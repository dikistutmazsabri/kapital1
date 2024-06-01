import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var timer: Timer?
    var appViewModel = AppViewModel() // AppViewModel'i burada tanımlayın

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = ContentView().environmentObject(appViewModel)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        startSellingProducts()
    }

    func startSellingProducts() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.appViewModel.sellProducts()
        }
    }

    func stopSellingProducts() {
        timer?.invalidate()
        timer = nil
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        stopSellingProducts()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        stopSellingProducts()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        startSellingProducts()
    }
}
