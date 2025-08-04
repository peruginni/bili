import App
import SnapshotTesting
import SwiftUI

func assertAppStoreSnapshots<Description, SnapshotContent>(
  for view: SnapshotContent,
  @ViewBuilder description: @escaping () -> Description,
  backgroundColor: Color,
  colorScheme: ColorScheme,
  variations: [String: SnapshotConfig],
  precision: Float = 0.98,
  perceptualPrecision: Float = 0.98,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
)
where
  SnapshotContent: View,
  Description: View
{
  for (name, config) in variations {
    var transaction = Transaction(animation: nil)
    transaction.disablesAnimations = false
    withTransaction(transaction) {
      assertSnapshot(
        matching: AppStorePreview(
            .image(layout: .device(config: config.viewImageConfig)),
          description: description,
          backgroundColor: backgroundColor,
          config: config
        ) {
          view
            .environment(\.colorScheme, colorScheme)
        }
        .environment(\.colorScheme, colorScheme),
        as: .image(
          precision: precision,
          perceptualPrecision: perceptualPrecision,
          layout: .device(config: config.viewImageConfig)
        ),
        named: name,
        file: file,
        testName: testName,
        line: line
      )
    }
  }
}
