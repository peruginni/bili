
import Foundation

public enum Log {
    public static func debug(_ string: String) {
#if DEBUG
        print(string)
#endif
    }
}
