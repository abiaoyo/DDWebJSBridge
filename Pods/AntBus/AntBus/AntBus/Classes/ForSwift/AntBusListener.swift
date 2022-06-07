import Foundation

public typealias AntBusListenerHandler = (_ oldVal: Any?, _ newVal: Any?) -> Void

public final class AntBusListener
{
    public static let shared = AntBusListener()
    
    private var AntBusListener_container_key: Void?
    
    public func listening(keyPath: String, for object: AnyObject, handler: AntBusListenerHandler!)
    {
        var container = objc_getAssociatedObject(object, &AntBusListener_container_key) as? AntBusListenerContainer
        
        if container == nil
        {
            container = AntBusListenerContainer(target: object)
            objc_setAssociatedObject(object, &AntBusListener_container_key, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            AntBusDeallocHook.shared.installDeallocHook(for: object, propertyKey: "AntBusListener", handlerKey: "AntBusListenerHandler")
            { _ in
                container?.removeKVO()
            }
        }
        container?.addMonitoring(keyPath: keyPath, handler: handler)
    }
    
    public func removeListening(keyPath: String, for object: AnyObject)
    {
        let container = objc_getAssociatedObject(object, &AntBusListener_container_key) as? AntBusListenerContainer
        container?.removeMonitoring(keyPath: keyPath)
    }
}

private class AntBusListenerContainer: NSObject
{
    weak var target: AnyObject?
    var container = NSMutableDictionary()
    
    init(target: AnyObject)
    {
        self.target = target
    }
    
    func removeKVO()
    {
        self.target?.removeObserver(self)
    }
    
    func addMonitoring(keyPath: String, handler: AntBusListenerHandler!)
    {
        var handlerContainers = container.object(forKey: keyPath) as? NSMutableArray
        if handlerContainers == nil
        {
            handlerContainers = NSMutableArray()
            container.setObject(handlerContainers!, forKey: keyPath as NSString)
            self.target?.addObserver(self, forKeyPath: keyPath, options: [.new, .old], context: nil)
        }
        handlerContainers?.add(handler as AnyObject)
    }
    
    func removeMonitoring(keyPath: String)
    {
        if let handlerContainers = container.object(forKey: keyPath) as? NSMutableArray
        {
            if handlerContainers.count > 0
            {
                self.target?.removeObserver(self, forKeyPath: keyPath, context: nil)
            }
        }
        container.removeObject(forKey: keyPath as NSString)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?)
    {
        if let _ = keyPath
        {
            let oldVal: Any? = change?[NSKeyValueChangeKey.oldKey]
            let newVal: Any? = change?[NSKeyValueChangeKey.newKey]
            
            if let handlerContainers = container.object(forKey: keyPath!) as? NSMutableArray
            {
                for handler in handlerContainers
                {
                    (handler as? AntBusListenerHandler)?(oldVal, newVal)
                }
            }
        }
    }
}
