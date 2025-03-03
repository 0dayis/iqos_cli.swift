import Foundation
import SwiftTUI

struct Cli {
    let arguments: [String]
    let ble = BluetoothCLI()

    init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    func view_prompt(title: String, inputLabel: String, child: String) {
        print("\n--- \(title) ---")
        print(child)
        print("\(inputLabel)> ", terminator: "")
    }

    func run() {
        ble.run()
        Application(rootView: ble.container).start()
        // ble.onDone = {
        //     // print(ble.iqosIlumaI)
        //     // ble.iqosIlumaI.view()
        // }
        RunLoop.main.run()
    }
}