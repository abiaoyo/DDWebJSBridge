import Foundation

public enum TypeUtil {
    public static func isClass(_ responder: Any) -> Bool {
        return Mirror(reflecting: responder).displayStyle == .class
    }

    public static func isStruct(_ responder: Any) -> Bool {
        return Mirror(reflecting: responder).displayStyle == .struct
    }

    public static func isEnum(_ responder: Any) -> Bool {
        return Mirror(reflecting: responder).displayStyle == .enum
    }
}

enum AliasUtil {
    private struct Alias {
        var name: String!
        var type: Any!
        
        static func create(_ group: String, type: Any) -> Alias {
            let name = "\(group)_\(Int(Date().timeIntervalSince1970)%10000)_\(arc4random()%1000)"
            return Alias(name: name, type: type)
        }
    }
    
    private static var aliasGroups = Dictionary<String, [Alias]>.init()
    
    private static func _aliasName(aliasArray: [Alias], interface: AnyObject) -> String? {
        for alias in aliasArray {
            if interface === alias.type as AnyObject {
                return alias.name
            }
            if let aType = alias.type as AnyObject? {
                if interface === aType {
                    return alias.name
                }
            }
        }
        return nil
    }
    
    private static func _aliasName(aliasArray: [Alias], itype: Any.Type) -> String? {
        for alias in aliasArray {
            if itype == alias.type as? Any.Type {
                return alias.name
            }
            if let iType = itype as AnyObject? {
                if let aType = alias.type as AnyObject? {
                    if iType === aType {
                        return alias.name
                    }
                }
            }
        }
        return nil
    }
    
    // -----------------------------------------------------------
    
    private static func _aliasName(groupKey: String, interface: AnyObject) -> String {
        guard let aliasArray = aliasGroups[groupKey] else {
            let alias = Alias.create(groupKey, type: interface)
            aliasGroups[groupKey] = [alias]
            return alias.name
        }
        
        if let name = _aliasName(aliasArray: aliasArray, interface: interface) {
            return name
        }
        let alias = Alias.create(groupKey, type: interface)
        aliasGroups[groupKey]?.append(alias)
        return alias.name
    }
    
    private static func _aliasName(groupKey: String, itype: Any.Type) -> String {
        guard let aliasArray = aliasGroups[groupKey] else {
            let alias = Alias.create(groupKey, type: itype)
            aliasGroups[groupKey] = [alias]
            return alias.name
        }
        if let name = _aliasName(aliasArray: aliasArray, itype: itype) {
            return name
        }
        let alias = Alias.create(groupKey, type: itype)
        aliasGroups[groupKey]?.append(alias)
        return alias.name
    }
}

extension AliasUtil {
    static func aliasForInterface(_ interface: Protocol) -> String {
        let typeName = NSStringFromProtocol(interface)
        let groupKey = typeName.components(separatedBy: ".").last!
        return _aliasName(groupKey: groupKey, interface: interface)
    }
    
    static func aliasForAnyObject(_ type: AnyObject.Type) -> String {
        return _aliasName(groupKey: "\(type)", itype: type)
    }
    
    static func aliasForAny<T: Any>(_ type: T.Type) -> String {
        return _aliasName(groupKey: "\(type)", itype: type)
    }
}
