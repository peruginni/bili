import ComposableArchitecture
import App
import SnapshotTesting
import SwiftUI
import XCTest


public enum AdaptiveSize {
    case small
    case medium
    case large
    
    public func pad(_ other: CGFloat, by scale: CGFloat = 1) -> CGFloat {
        self.padding * scale + other
    }
    
    public var padding: CGFloat {
        switch self {
        case .small:
            return 0
        case .medium:
            return 10
        case .large:
            return 20
        }
    }
}
struct SnapshotConfig {
    let idiom: UIUserInterfaceIdiom
    let viewImageConfig: ViewImageConfig
    let offset: Int
    let descriptionFont: Font
}

let appStoreViewConfigs: [String: SnapshotConfig] = [
    "iPhone_5_5": .init(
        idiom: .phone,
        viewImageConfig: .iPhone8Plus,
        offset: 20,
        descriptionFont: .system(size: 30)
    ),
    "iPhone_6_5": .init(
        idiom: .phone,
        viewImageConfig: .iPhoneXsMax,
        offset: 25,
        descriptionFont: .system(size: 30)
    ),
    "iPad_12_9": .init(
        idiom: .pad,
        viewImageConfig: .iPadPro12_9(.portrait),
        offset: 40,
        descriptionFont: .system(size: 75)
    ),
]

let appStoreViewConfigs_threeLines: [String: SnapshotConfig] = [
    "iPhone_5_5": .init(
        idiom: .phone,
        viewImageConfig: .iPhone8Plus,
        offset: 20,
        descriptionFont: .system(size: 25)
    ),
    "iPhone_6_5": .init(
        idiom: .phone,
        viewImageConfig: .iPhoneXsMax,
        offset: 25,
        descriptionFont: .system(size: 25)
    ),
    "iPad_12_9": .init(
        idiom: .pad,
        viewImageConfig: .iPadPro12_9(.portrait),
        offset: 40,
        descriptionFont: .system(size: 75)
    ),
]

class AppStoreSnapshotTests: XCTestCase {
  static override func setUp() {
    super.setUp()
    isRecording = true
//    SnapshotTesting.diffTool = "ksdiff"
  }

  override func setUpWithError() throws {
    try super.setUpWithError()
//    try XCTSkipIf(!Styleguide.registerFonts())
    isRecording = true
  }

  override func tearDown() {
    isRecording = false
    super.tearDown()
  }

    func test_1_CapturePhoto() {
        assertAppStoreSnapshots(
            for: capturePhotoView,
            description: {
                Text("Take photo of words\nyou don't know. Yet!")
                    .foregroundColor(.white)
            },
            backgroundColor: .myRed,
            colorScheme: .dark,
            variations: appStoreViewConfigs
        )
    }
    
    func test_2_CapturedSnap() {
        assertAppStoreSnapshots(
            for: capturedSnapView,
            description: {
                Text("Focus on unknown words")
                    .foregroundColor(.black)
            },
            backgroundColor: .myYellow,
            colorScheme: .light,
            variations: appStoreViewConfigs
        )
    }
    
    func test_2_ExerciseSession() {
        assertAppStoreSnapshots(
            for: exerciseSessionView,
            description: {
                Text("Listen words while\nrunning or cooking.")
                    .foregroundColor(.white)
            },
            backgroundColor: .myBlue,
            colorScheme: .light,
            variations: appStoreViewConfigs
        )
    }
}

extension Color {
    static let myBlue = Color(hex: 0x017AFF)
    static let myRed = Color(hex: 0xFF005A)
    static let myYellow = Color(hex: 0xFFC600)
    static let myPurple = Color(hex: 0xA70BFF)
    static let myGray = Color(hex: 0xA7A7A7)
    
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
