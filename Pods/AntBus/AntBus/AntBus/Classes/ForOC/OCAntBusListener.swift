import Foundation

@objcMembers
public class OCAntBusListener: NSObject {
    
    public static let shared = OCAntBusListener()
    
    public func listening(keyPath: String, forObject obj: AnyObject, handler: AntBusListenerHandler!) {
        AntBusListener.shared.listening(keyPath: keyPath, for: obj, handler: handler)
    }
    
    public func removeListening(keyPath: String, forObject obj: AnyObject) {
        AntBusListener.shared.removeListening(keyPath: keyPath, for: obj)
    }
}
