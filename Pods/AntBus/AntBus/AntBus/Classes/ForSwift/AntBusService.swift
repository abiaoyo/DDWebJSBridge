import Foundation

// Single
struct AntBusSSC {
    static var container = [String: Any]()
    
    static func register(_ key: String, _ responder: Any) {
        let log = "AntBus.service.single.register:  \(key) \t \(responder)"
        AntBus.serviceLog?(log)
        
        container[key] = responder
    }
    
    static func responder(_ key: String) -> Any? {
        let rs = container[key]
        
        let log = "AntBus.service.single.responder:  \(key) \t \(String(describing: rs))"
        AntBus.serviceLog?(log)
        
        return rs
    }
    
    static func remove(_ key: String) {
        let log = "AntBus.service.single.remove:  \(key)"
        AntBus.serviceLog?(log)
        
        container.removeValue(forKey: key)
    }
    
    static func removeAll() {
        let log = "AntBus.service.single.removeAll"
        AntBus.serviceLog?(log)
        
        container.removeAll()
    }
}

// Multi
enum AntBusSMC {
    static var container = [String: [String: [Any]]]()
    
    static func register(_ type: String, _ key: String, _ responder: Any) {
        let log = "AntBus.service.multi.register:  \(type) \t \(key) \t \(responder)"
        AntBus.serviceLog?(log)
        if let _ = container[type] {
            if let _ = container[type]![key] {
                container[type]![key]?.append(responder)
            } else {
                container[type]![key] = [responder]
            }
        } else {
            let responders = [responder]
            let keyContainers = [key: responders]
            container.updateValue(keyContainers, forKey: type)
        }
    }
    
    static func register(_ type: String, _ keys: [String], _ responder: Any) {
        for key in keys {
            register(type, key, responder)
        }
    }
    
    static func register(_ type: String, _ key: String, _ responders: [Any]) {
        for responder in responders {
            register(type, key, responder)
        }
    }
    
    static func responders(_ type: String, _ key: String) -> [Any]? {
        let rs = container[type]?[key]
        
        let log = "AntBus.service.multi.responders:  \(type) \t \(key) \t \(String(describing: rs))"
        AntBus.serviceLog?(log)
        
        return rs
    }
    
    static func responders(_ type: String) -> [Any]? {
        let typeContainer = container[type]
        let results = typeContainer?.flatMap { $0.value }
        let uniqueResults = NSMutableSet(array: results ?? [])
        let rs = uniqueResults.allObjects
        
        let log = "AntBus.service.multi.responders:  \(type) \t \(String(describing: rs))"
        AntBus.serviceLog?(log)
        
        return rs
    }
    
    static func remove(_ type: String, _ key: String, where shouldBeRemoved: (Any) -> Bool) {
        let log = "AntBus.service.multi.remove:  \(type) \t \(key) \t where: .."
        AntBus.serviceLog?(log)
        
        container[type]?[key]?.removeAll(where: { r in
            shouldBeRemoved(r)
        })
    }
    
    static func remove(_ type: String, _ key: String) {
        let log = "AntBus.service.multi.remove:  \(type) \t \(key)"
        AntBus.serviceLog?(log)
        
        container[type]?.removeValue(forKey: key)
    }
    
    static func remove(_ type: String) {
        let log = "AntBus.service.multi.remove:  \(type)"
        AntBus.serviceLog?(log)
        
        container.removeValue(forKey: type)
    }
}
