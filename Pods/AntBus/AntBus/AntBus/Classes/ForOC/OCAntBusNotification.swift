import Foundation

@objcMembers
public class OCAntBusNotification: NSObject {
    public static let shared = OCAntBusNotification()
    
    public func register(key: String, owner: AnyObject, handler: @escaping AntBusNotification.NotificationHandler) {
        AntBus.notification.register(key, owner: owner, handler: handler)
    }
    
    public func post(key: String, data: Any?) {
        AntBus.notification.post(key, data: data)
    }
    
    public func post(key: String) {
        AntBus.notification.post(key)
    }
    
    public func remove(key: String, owner: AnyObject) {
        AntBus.notification.remove(key, owner: owner)
    }
    
    public func remove(key: String) {
        AntBus.notification.remove(key)
    }
    
    public func remove(owner: AnyObject) {
        AntBus.notification.remove(owner: owner)
    }
    
    public func removeAll() {
        AntBus.notification.removeAll()
    }
}
