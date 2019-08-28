//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import SwiftUI

import KeychainSwift

typealias Screen = View
typealias AnyScreen = AnyView

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

//    private let appCoordinator = AppCoordinator(keychainStore: KeyValueStore(KeychainSwift()), preferences: .default)

    fileprivate lazy var appCoordinator: AppCoordinator = {
        let rootViewController = UIHostingController(rootView: AnyScreen(EmptyView()))

        window?.rootViewController = rootViewController

        return AppCoordinator(
            dependencies: (
                keychainStore: KeyValueStore(KeychainSwift()),
                preferences: .default
            )
        ) { [unowned rootViewController] (newRootScreen: AnyScreen) in
            rootViewController.rootView = newRootScreen
        }
    }()


    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        self.window = .fromScene(scene)
        appCoordinator.start()
    }
}


extension UIWindow {
    static func fromScene(_ scene: UIScene) -> UIWindow {
        guard let windowScene = scene as? UIWindowScene else { fatalError("Unable to start app") }
        let window = UIWindow(windowScene: windowScene)
        window.makeKeyAndVisible()
        return window
    }
}