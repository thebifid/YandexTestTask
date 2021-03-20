//
//  NetworkMonitor.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 18.03.2021.
//

import Foundation
import Network

/// Class for monitoring Internet Connection status (IC)
class NetworkMonitor {
    private init() { monitor = NWPathMonitor() }

    static let sharedInstance = NetworkMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor

    private(set) var isConnected: Bool = false {
        didSet {
            didUpdateNetworkState?(isConnected)
        }
    }

    enum ConnectionStatus: Error {
        case connected(Error)
        case notConnected
    }

    var didUpdateNetworkState: ((Bool) -> Void)?

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
