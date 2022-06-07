import Foundation

public enum AntBus {
    public static let data = AntBusData.shared
    public static let notification = AntBusNotification.shared
    public static let callback = AntBusCallback.shared
    public static let deallocHook = AntBusDeallocHook.shared
    public static let listener = AntBusListener.shared
}

// weak -> responder
public extension AntBus {
    struct channel<T: Any> {
        public enum single {
            public static func all() -> NSDictionary {
                return AntBusCSC.container.dictionaryRepresentation() as NSDictionary
            }

            // ------------------
            public static func register(_ responder: T) {
                if !TypeUtil.isClass(responder) {
                    assertionFailure("🍄🍄🍄🍄🍄🍄 responder must be of class type")
                    return
                }
                let name = AliasUtil.aliasForAny(T.self)
                AntBusCSC.register(name, responder as AnyObject)
            }

            public static func responder() -> T? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusCSC.responder(name) as? T
            }

            public static func remove() {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusCSC.remove(name)
            }
        }

        public enum multi {
            public static func all() -> NSDictionary {
                return AntBusCMC.container.copy() as! NSDictionary
            }

            // ------------------
            public static func register(_ responder: T, forKey key: String) {
                if !TypeUtil.isClass(responder) {
                    assertionFailure("🍄🍄🍄🍄🍄🍄 responder must be of class type")
                    return
                }

                let aliasName = AliasUtil.aliasForAny(T.self)
                AntBusCMC.register(aliasName, key, responder as AnyObject)
            }

            public static func register(_ responders: [T], forKey key: String) {
                responders.forEach { responder in
                    register(responder, forKey: key)
                }
            }

            public static func register(_ responder: T, forKeys keys: [String]) {
                keys.forEach { key in
                    register(responder, forKey: key)
                }
            }

            // ------------------
            public static func responders(_ key: String) -> [T]? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusCMC.responders(name, key)?.compactMap { $0 as? T }
            }

            public static func responders() -> [T]? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusCMC.responders(name)?.compactMap { $0 as? T }
            }

            // ------------------
            public static func remove(_ responder: T, forKey key: String) {
                if !TypeUtil.isClass(responder) {
                    assertionFailure("🍄🍄🍄🍄🍄🍄 responder must be of class type")
                    return
                }
                let name = AliasUtil.aliasForAny(T.self)
                AntBusCMC.remove(name, key, responder as AnyObject)
            }

            public static func remove(_ responder: T, forKeys keys: [String]) {
                keys.forEach { key in
                    remove(responder, forKey: key)
                }
            }

            public static func remove(_ responders: [T], forKey key: String) {
                responders.forEach { responder in
                    remove(responder, forKey: key)
                }
            }

            public static func remove(_ key: String) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusCMC.remove(name, key)
            }

            public static func remove(_ keys: [String]) {
                let name = AliasUtil.aliasForAny(T.self)
                keys.forEach { key in
                    AntBusCMC.remove(name, key)
                }
            }

            public static func remove() {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusCMC.remove(name)
            }
        }
    }
}

public extension AntBus {
    // strong -> responder
    struct service<T: Any> {
        public enum single {
            public static func all() -> [String: Any] {
                return AntBusSSC.container
            }

            public static func register(_ responder: T) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSSC.register(name, responder)
            }

            public static func responder() -> T? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusSSC.responder(name) as? T
            }

            public static func remove() {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSSC.remove(name)
            }
        }

        public enum multi {
            public static func all() -> [String: [String: [Any]]] {
                return AntBusSMC.container
            }

            public static func register(_ responder: T, forKey key: String) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.register(name, key, responder)
            }

            public static func register(_ responder: T, forKeys keys: [String]) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.register(name, keys, responder)
            }

            public static func register(_ responders: [T], forKey key: String) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.register(name, key, responders)
            }

            public static func responders(forKey key: String) -> [T]? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusSMC.responders(name, key)?.compactMap { $0 as? T }
            }

            public static func responders() -> [T]? {
                let name = AliasUtil.aliasForAny(T.self)
                return AntBusSMC.responders(name)?.compactMap { $0 as? T }
            }

            public static func remove(forKey key: String, where shouldBeRemoved: (T) -> Bool) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.remove(name, key) { resp in
                    shouldBeRemoved(resp as! T)
                }
            }

            public static func remove(forKey key: String) {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.remove(name, key)
            }

            public static func remove(forKeys keys: [String]) {
                let name = AliasUtil.aliasForAny(T.self)
                keys.forEach { key in
                    AntBusSMC.remove(name, key)
                }
            }

            public static func remove() {
                let name = AliasUtil.aliasForAny(T.self)
                AntBusSMC.remove(name)
            }
        }
    }
}

public extension AntBus {
    static var deallocLog: ((_ log: String) -> Void)?
    static var channelLog: ((_ log: String) -> Void)?
    static var serviceLog: ((_ log: String) -> Void)?

    static func printLog(_ str: String) {
        print("###🍄 \(str)")
    }
}
