import Foundation
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
        ble.onDone = {
            print(ble.iqosIlumaI)
        }
        RunLoop.main.run()
    }
}