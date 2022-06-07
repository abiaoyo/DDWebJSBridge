import Foundation

@objcMembers
public class OCAntBusDeallocHook: NSObject {
    public static let shared = OCAntBusDeallocHook()
    
    public func installDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String, handler: AntBusDeallocHandler?) {
        AntBusDeallocHook.shared.installDeallocHook(for: object, propertyKey: propertyKey, handlerKey: handlerKey, handler: handler)
    }
    
    public func uninstallDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String) {
        AntBusDeallocHook.shared.uninstallDeallocHook(for: object, propertyKey: propertyKey, handlerKey: handlerKey)
    }
    
    public func uninstallDeallocHook(for object: AnyObject, propertyKey: String) {
        AntBusDeallocHook.shared.uninstallDeallocHook(for: object, propertyKey: propertyKey)
    }
}
