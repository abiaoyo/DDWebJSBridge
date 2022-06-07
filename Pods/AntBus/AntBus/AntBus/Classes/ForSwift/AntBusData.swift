import Foundation

public final class AntBusData {
    public typealias DataHandler = () -> Any?
    
    public static let shared = AntBusData()
    
    // <key,owner>
    private static var keyOwnerMap = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    // <owner,[<key,handler>]>
    private static var ownerHandlersMap = WeakMapTable<AnyObject, NSMapTable<NSString, AnyObject>>.init()
    
    private func clearOwner(_ key: String) {
        guard let owner = AntBusData.keyOwnerMap.object(forKey: key as NSString) else {
            return
        }
        AntBusData.ownerHandlersMap.value(forKey: owner)?.removeObject(forKey: key as NSString?)
    }
    
    private func handler(forKey key: String) -> DataHandler? {
        guard let owner = AntBusData.keyOwnerMap.object(forKey: key as NSString) else {
            return nil
        }
        return AntBusData.ownerHandlersMap.value(forKey: owner)?.object(forKey: key as NSString) as? DataHandler
    }
}

public extension AntBusData {
    func register(_ key: String, owner: AnyObject, handler: @escaping DataHandler) {
        clearOwner(key)
        
        AntBusData.keyOwnerMap.setObject(owner, forKey: key as NSString)
        
        let khMap = AntBusData.ownerHandlersMap.value(forKey: owner) ?? NSMapTable<NSString, AnyObject>.strongToStrongObjects()

        khMap.setObject(handler as AnyObject, forKey: key as NSString)
        
        AntBusData.ownerHandlersMap.setValue(khMap, forKey: owner)
        
        AntBusDeallocHook.shared.installDeallocHook(for: owner, propertyKey: "AntBusData", handlerKey: key) { _ in
            AntBusData.keyOwnerMap.removeObject(forKey: key as NSString)
        }
    }
    
    func canCall(_ key: String) -> Bool {
        return handler(forKey: key) != nil
    }
    
    func call(_ key: String) -> Any? {
        guard let handler = handler(forKey: key) else {
            return nil
        }
        return handler()
    }
    
    func remove(_ key: String) {
        clearOwner(key)
    }
    
    func removeAll() {
        AntBusData.keyOwnerMap.removeAllObjects()
        AntBusData.ownerHandlersMap.removeAll()
    }
}
