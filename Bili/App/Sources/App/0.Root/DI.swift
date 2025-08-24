import ComposableArchitecture
import SwiftUI

@MainActor
public enum DI {
    static var userDefaultsRepository: UserDefaultsRepository = UserDefaultsRepositoryImpl()
    static var cameraModel: CameraClientObservableWrapper = CameraClientObservableWrapper(CameraClientLive())
    
    public struct Factory<Service> {
        public typealias Factory = () -> Service
        var factory: Factory
        
        public init(factory: @escaping Factory) {
            self.factory = factory
        }
        
        public func callAsFunction() -> Service {
            factory()
        }
        
        public mutating func mock(_ factory: @escaping @autoclosure Factory) {
            self.factory = factory
        }
    }
}

@propertyWrapper
public struct Injected<T> {
    var dependency: T
    
    public var wrappedValue: T {
        get { dependency }
        set { dependency = newValue }
    }
    
    public init(_ factory: DI.Factory<T>) {
        self.dependency = factory()
    }
}
