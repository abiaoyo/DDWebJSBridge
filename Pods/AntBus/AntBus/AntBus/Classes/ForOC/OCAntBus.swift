import Foundation

@objcMembers
public class OCAntBus: NSObject {
    public static let data = OCAntBusData.shared
    public static let notification = OCAntBusNotification.shared
    public static let callback = OCAntBusCallback.shared
    public static let deallocHook = OCAntBusDeallocHook.shared
    public static let listener = OCAntBusListener.shared
    public static let channel = OCAntBusChannel.shared
    public static let service = OCAntBusService.shared
}

public extension OCAntBus {
    static var deallocLog: ((_ log: String) -> Void)? {
        set { AntBus.deallocLog = newValue }
        get { return AntBus.deallocLog }
    }

    static var channelLog: ((_ log: String) -> Void)? {
        set { AntBus.channelLog = newValue }
        get { return AntBus.channelLog }
    }

    static var serviceLog: ((_ log: String) -> Void)? {
        set { AntBus.serviceLog = newValue }
        get { return AntBus.serviceLog }
    }
    
    static func printLog(_ str: String) {
        AntBus.printLog(str)
    }
}
