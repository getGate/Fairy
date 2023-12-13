import MetricKit
import SwiftUI
import Foundation
import UIKit
import Popovers

protocol FairyPlugin {
    func start()
}

public struct FairyContext {
    let rootWindow: UIWindow?

    public init(rootWindow: UIWindow?) {
        self.rootWindow = rootWindow
    }
}

/// Fairy is an Utility build to help you debug crashes, hangs and slow rendering etc
public class Fairy {
    public static let `default` = Fairy()

    lazy var plugins: [FairyPlugin] = [
        MetricKitPlugin(),
    ]

    /// I am the sword in darkness and now my watch begins
    public func startWatch() {

        for plugin in plugins {
            plugin.start()
        }
    }
}
