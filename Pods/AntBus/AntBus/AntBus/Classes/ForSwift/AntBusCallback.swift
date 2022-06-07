import Foundation

public struct AntBusCallback {
    public typealias ResponseHandler = (_ data: Any?) -> Void
    public typealias MethodHandler = (_ data: Any?, _ responseHandler: @escaping ResponseHandler) -> Void
    
    public static let shared = AntBusCallback()
    
    // <key,owner>
    private static var keyOwnerMap = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    // <owner,[<key,handler>]>
    private static var ownerHandlersMap = WeakMapTable<AnyObject, NSMapTable<NSString, AnyObject>>.init()
    
    private func clearOwner(_ key: String) {
        guard let owner = AntBusCallback.keyOwnerMap.object(forKey: key as NSString) else {
            return
        }
        AntBusCallback.ownerHandlersMap.value(forKey: owner)?.removeObject(forKey: key as NSString?)
    }
    
    private func handler(forKey key: String) -> MethodHandler? {
        guard let owner = AntBusCallback.keyOwnerMap.object(forKey: key as NSString) else {
            return nil
        }
        return AntBusCallback.ownerHandlersMap.value(forKey: owner)?.object(forKey: key as NSString) as? MethodHandler
    }
    
    public func register(_ key: String, owner: AnyObject, handler: @escaping MethodHandler) {
        if let oldOwner = AntBusCallback.keyOwnerMap.object(forKey: key as NSString), oldOwner !== owner {
            if let oldOmhMap = AntBusCallback.ownerHandlersMap.value(forKey: owner) {
                oldOmhMap.removeObject(forKey: key as NSString)
            }
        }
        
        AntBusCallback.keyOwnerMap.setObject(owner, forKey: key as NSString)
        
        let omhMap = AntBusCallback.ownerHandlersMap.value(forKey: owner) ?? NSMapTable<NSString, AnyObject>.strongToStrongObjects()
        omhMap.setObject(handler as AnyObject, forKey: key as NSString)
        
        AntBusCallback.ownerHandlersMap.setValue(omhMap, forKey: owner)
        
        AntBusDeallocHook.shared.installDeallocHook(for: owner, propertyKey: "AntBusCallback", handlerKey: key) { _ in
            AntBusCallback.keyOwnerMap.removeObject(forKey: key as NSString)
        }
    }
    
    public func call(_ key: String, data: Any?, responseHandler: ResponseHandler? = nil) {
        guard let owner = AntBusCallback.keyOwnerMap.object(forKey: key as NSString) else {
            return
        }
        guard let omhMap = AntBusCallback.ownerHandlersMap.value(forKey: owner) else {
            return
        }
        guard let handler = omhMap.object(forKey: key as NSString) as? MethodHandler else {
            return
        }
        handler(data, { data in
            responseHandler?(data)
        })
    }
    
    public func remove(forKey key: String) {
        clearOwner(key)
    }
    
    public func removeAll() {
        AntBusCallback.keyOwnerMap.removeAllObjects()
        AntBusCallback.ownerHandlersMap.removeAll()
    }
}
