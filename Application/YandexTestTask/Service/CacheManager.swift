//
//  CacheManager.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 23.03.2021.
//

import EasyStash
import os.log

class CacheManager {
    var storage: Storage?

    func saveCache<T: Codable>(object: T, forKey key: String) {
        do {
            try storage?.save(object: object, forKey: key)
        } catch {
            os_log("Failed to save data in cache. %{public}@", type: .error, error.localizedDescription)
        }
    }

    func saveBoolValue(value: Bool, forKey key: String) {
        do {
            try storage?.save(object: true, forKey: key)
        } catch {
            os_log("Failed to save data in cache. %{public}@", type: .error, error.localizedDescription)
        }
    }

    func loadCache<T: Codable>(forKey key: String, as type: T.Type, withExpiry expiry: Storage.Expiry = .never) -> T? {
        do {
            let result = try storage?.load(forKey: key, as: type, withExpiry: expiry)
            return result
        } catch {
            return nil
        }
    }

    func exists(forKey key: String) -> Bool {
        if let storage = storage {
            return storage.exists(forKey: key)
        }
        return false
    }

    private init() {
        var options: Options = Options()
        options.folder = "Cache"
        do {
            storage = try Storage(options: options)
        } catch {
            os_log("Failed to create storage. %{public}@", type: .error, error.localizedDescription)
        }
    }

    static let sharedInstance = CacheManager()
}
