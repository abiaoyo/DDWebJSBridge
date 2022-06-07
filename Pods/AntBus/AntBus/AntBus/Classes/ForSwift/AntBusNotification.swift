import Foundation

// MARK: - AntBusNotification

public final class AntBusNotification {
    public typealias NotificationHandler = (_ data: Any?) -> Void
    
    public static let shared = AntBusNotification()
    
    // <key,owners>
    private static var ownerContainer = Dictionary<String, NSHashTable<AnyObject>>.init()
    // <owner,[<key,handler>]>
    private static var handlerContainer = WeakMapTable<AnyObject, NSMapTable<NSString, AnyObject>>.init()
    
    public func register(_ key: String, owner: AnyObject, handler: @escaping NotificationHandler) {
        let oTable = AntBusNotification.ownerContainer[key] ?? NSHashTable<AnyObject>.weakObjects()
        oTable.add(owner)
        
        AntBusNotification.ownerContainer[key] = oTable
        
        let khMap = AntBusNotification.handlerContainer.value(forKey: owner) ?? NSMapTable<NSString, AnyObject>.strongToStrongObjects()
        khMap.setObject(handler as AnyObject, forKey: key as NSString)
        
        AntBusNotification.handlerContainer.setValue(khMap, forKey: owner)
        
        AntBusDeallocHook.shared.installDeallocHook(for: owner, propertyKey: "AntBusNotification", handlerKey: key) { hkeys in
            for hkey in hkeys {
                if AntBusNotification.ownerContainer[hkey]?.allObjects.count == 0 {
                    AntBusNotification.ownerContainer.removeValue(forKey: hkey)
                }
            }
        }
    }
    
    public func post(_ key: String, data: Any? = nil) {
        guard let oTable = AntBusNotification.ownerContainer[key] else {
            return
        }
        oTable.allObjects.forEach { owner in
            (AntBusNotification.handlerContainer.value(forKey: owner)?.object(forKey: key as NSString) as? NotificationHandler)?(data)
        }
    }
    
    public func remove(_ key: String, owner: AnyObject? = nil) {
        if let o = owner {
            AntBusNotification.ownerContainer[key]?.remove(o)
            AntBusNotification.handlerContainer.value(forKey: o)?.removeObject(forKey: key as NSString?)
        } else {
            guard let owners = AntBusNotification.ownerContainer[key] else {
                return
            }
            owners.allObjects.forEach { owner in
                AntBusNotification.handlerContainer.value(forKey: owner)?.removeObject(forKey: key as NSString?)
            }
            owners.removeAllObjects()
        }
    }
    
    public func remove(owner: AnyObject) {
        AntBusNotification.handlerContainer.remove(forKey: owner)
    }
    
    public func removeAll() {
        AntBusNotification.ownerContainer.removeAll()
        AntBusNotification.handlerContainer.removeAll()
    }
}
