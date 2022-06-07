import Foundation

@objcMembers
public class OCAntBusCallback: NSObject {
    public static let shared = OCAntBusCallback()
    
    public func register(key: String, owner: AnyObject, handler: @escaping AntBusCallback.MethodHandler) {
        AntBus.callback.register(key, owner: owner, handler: handler)
    }
    
    public func call(key: String, data: Any?, responseHandler: @escaping AntBusCallback.ResponseHandler) {
        AntBus.callback.call(key, data: data, responseHandler: responseHandler)
    }
    
    public func remove(forKey key: String) {
        AntBus.callback.remove(forKey: key)
    }
    
    public func removeAll() {
        AntBus.callback.removeAll()
    }
}
