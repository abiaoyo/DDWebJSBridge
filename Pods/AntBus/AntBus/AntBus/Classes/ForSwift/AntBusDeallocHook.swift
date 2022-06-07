import Foundation

public typealias AntBusDeallocHandler = (_ handleKeys: Set<String>) -> Void

private class _AntBusDeallocHook {
    private var handlerKeys = Set<String>.init()
    
    var handler: AntBusDeallocHandler?
    var type: String?
    var propertyKey: String = ""
    
    func add(_ handlerKey: String) {
        handlerKeys.insert(handlerKey)
    }
    
    func remove(_ handlerKey: String) {
        handlerKeys.remove(handlerKey)
    }
    
    deinit {
        let log = "AntBusDeallocHook deinit: .type:\(type ?? "") \t .pKey:\(propertyKey) \t .hKey:\(handlerKeys)"
        AntBus.deallocLog?(log)
        
        handler?(handlerKeys)
    }
}

public final class AntBusDeallocHook {
    public static let shared = AntBusDeallocHook()
    
    private init() {}
    
    private var AntBusDeallocHookKey: Void?
    
    public func installDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String, handler: AntBusDeallocHandler?) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        
        guard let hook = objc_getAssociatedObject(object, keyPointer) as? _AntBusDeallocHook else {
            let _hook = _AntBusDeallocHook()
            _hook.propertyKey = propertyKey
            _hook.handler = handler
            _hook.type = "\(type(of: object))"
            _hook.add(handlerKey)
            objc_setAssociatedObject(object, keyPointer, _hook, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            let log = "AntBusDeallocHook install _new: .type:\(_hook.type ?? "") \t .pKey:\(_hook.propertyKey) \t .hKey:\(handlerKey)"
            AntBus.deallocLog?(log)
            
            return
        }
        hook.add(handlerKey)
        
        let log = "AntBusDeallocHook install _add: .type:\(hook.type ?? "") \t .pKey:\(hook.propertyKey) \t .hKey:\(handlerKey)"
        AntBus.deallocLog?(log)
    }
    
    public func uninstallDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        let hook = objc_getAssociatedObject(object, keyPointer) as? _AntBusDeallocHook
        hook?.remove(handlerKey)
        
        let log = "AntBusDeallocHook uninstall: .type:\(hook!.type ?? "") \t .pKey:\(hook!.propertyKey) \t .hKey:\(handlerKey)"
        AntBus.deallocLog?(log)
    }
    
    public func uninstallDeallocHook(for object: AnyObject, propertyKey: String) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        objc_setAssociatedObject(object, keyPointer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let log = "AntBusDeallocHook uninstall: .type:\(type(of: object)) \t .pKey:\(propertyKey)"
        AntBus.deallocLog?(log)
    }
}
