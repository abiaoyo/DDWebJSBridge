import Foundation

@objcMembers
public class OCAntBusServiceSS: NSObject {
    public func all() -> [String: Any] {
        return AntBusSSC.container
    }

    public func register(interface: Protocol, responder: AnyObject) {
        let name = AliasUtil.aliasForInterface(interface)
        AntBusSSC.register(name, responder)
    }

    public func register(clazz: AnyObject.Type, responder: AnyObject) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        AntBusSSC.register(name, responder)
    }

    public func responder(interface: Protocol) -> AnyObject? {
        let name = AliasUtil.aliasForInterface(interface)
        return AntBusSSC.responder(name) as AnyObject?
    }

    public func responder(clazz: AnyObject.Type) -> AnyObject? {
        let name = AliasUtil.aliasForAnyObject(clazz)
        return AntBusSSC.responder(name) as AnyObject?
    }

    public func remove(interface: Protocol) {
        let name = AliasUtil.aliasForInterface(interface)
        AntBusSSC.remove(name)
    }

    public func remove(clazz: AnyObject.Type) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        AntBusSSC.remove(name)
    }

    public func removeAll() {
        AntBusSSC.removeAll()
    }
}

@objcMembers
public class OCAntBusServiceSM: NSObject {
    public func all() -> [String: [String: [Any]]] {
        return AntBusSMC.container
    }

    private func conformsInterface(interface: Protocol, responder: AnyObject) -> Bool {
        return responder.conforms(to: interface)
    }

    private func isKindOfClazz(clazz: AnyObject.Type, responder: AnyObject) -> Bool {
        return responder.isKind(of: clazz)
    }

    // -------
    public func register(interface: Protocol, key: String, responder: AnyObject) {
        if conformsInterface(interface: interface, responder: responder) {
            let name = AliasUtil.aliasForInterface(interface)
            AntBusSMC.register(name, key, responder)
        }
    }

    public func register(clazz: AnyObject.Type, key: String, responder: AnyObject) {
        if isKindOfClazz(clazz: clazz, responder: responder) {
            let name = AliasUtil.aliasForAnyObject(clazz)
            AntBusSMC.register(name, key, responder)
        }
    }

    public func register(interface: Protocol, forKeys keys: [String], responder: AnyObject) {
        if conformsInterface(interface: interface, responder: responder) {
            let name = AliasUtil.aliasForInterface(interface)
            AntBusSMC.register(name, keys, responder)
        }
    }

    public func register(clazz: AnyObject.Type, forKeys keys: [String], responder: AnyObject) {
        if isKindOfClazz(clazz: clazz, responder: responder) {
            let name = AliasUtil.aliasForAnyObject(clazz)
            AntBusSMC.register(name, keys, responder)
        }
    }

    public func register(interface: Protocol, key: String, responders: NSArray) {
        if let _resps = responders as [AnyObject]? {
            let name = AliasUtil.aliasForInterface(interface)
            for resp in _resps {
                if conformsInterface(interface: interface, responder: resp) {
                    AntBusSMC.register(name, key, resp)
                }
            }
        }
    }

    public func register(clazz: AnyObject.Type, key: String, responders: NSArray) {
        if let _resps = responders as [AnyObject]? {
            let name = AliasUtil.aliasForAnyObject(clazz)
            for resp in _resps {
                if isKindOfClazz(clazz: clazz, responder: resp) {
                    AntBusSMC.register(name, key, resp)
                }
            }
        }
    }

    // -------
    public func responder(interface: Protocol, key: String) -> NSArray? {
        let name = AliasUtil.aliasForInterface(interface)
        return AntBusSMC.responders(name, key) as NSArray?
    }

    public func responder(clazz: AnyObject.Type, key: String) -> NSArray? {
        let name = AliasUtil.aliasForAnyObject(clazz)
        return AntBusSMC.responders(name, key) as NSArray?
    }

    public func responder(interface: Protocol) -> NSArray? {
        let name = AliasUtil.aliasForInterface(interface)
        return AntBusSMC.responders(name) as NSArray?
    }

    public func responder(clazz: AnyObject.Type) -> NSArray? {
        let name = AliasUtil.aliasForAnyObject(clazz)
        return AntBusSMC.responders(name) as NSArray?
    }

    // -------
    public func remove(interface: Protocol, key: String, responder: AnyObject) {
        let name = AliasUtil.aliasForInterface(interface)
        AntBusSMC.remove(name, key) { smResp in
            if let resp: AnyObject = smResp as AnyObject? {
                return resp === responder
            }
            return false
        }
    }

    public func remove(clazz: AnyObject.Type, key: String, responder: AnyObject) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        AntBusSMC.remove(name, key) { smResp in
            if let resp: AnyObject = smResp as AnyObject? {
                return resp === responder
            }
            return false
        }
    }

    public func remove(interface: Protocol, forKeys keys: [String], responder: AnyObject) {
        let name = AliasUtil.aliasForInterface(interface)
        for key in keys {
            AntBusSMC.remove(name, key) { smResp in
                if let resp: AnyObject = smResp as AnyObject? {
                    return resp === responder
                }
                return false
            }
        }
    }

    public func remove(clazz: AnyObject.Type, key: String, responders: NSArray) {
        if let _responders = responders as [AnyObject]? {
            let name = AliasUtil.aliasForAnyObject(clazz)
            for responder in _responders {
                AntBusSMC.remove(name, key) { smResp in
                    if let resp: AnyObject = smResp as AnyObject? {
                        return resp === responder
                    }
                    return false
                }
            }
        }
    }

    public func remove(interface: Protocol, forKeys keys: [String]) {
        let name = AliasUtil.aliasForInterface(interface)
        for key in keys {
            AntBusSMC.remove(name, key)
        }
    }

    public func remove(clazz: AnyObject.Type, forKeys keys: [String]) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        for key in keys {
            AntBusSMC.remove(name, key)
        }
    }

    public func remove(interface: Protocol, key: String) {
        let name = AliasUtil.aliasForInterface(interface)
        AntBusSMC.remove(name, key)
    }

    public func remove(clazz: AnyObject.Type, key: String) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        AntBusSMC.remove(name, key)
    }

    public func remove(interface: Protocol) {
        let name = AliasUtil.aliasForInterface(interface)
        AntBusSMC.remove(name)
    }

    public func remove(clazz: AnyObject.Type) {
        let name = AliasUtil.aliasForAnyObject(clazz)
        AntBusSMC.remove(name)
    }
}

@objcMembers
public class OCAntBusService: NSObject {
    public static let shared = OCAntBusService()

    public let single = OCAntBusServiceSS()
    public let multi = OCAntBusServiceSM()
}
