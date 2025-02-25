// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

@main
struct IqosCli {
    static func main() {
        let bluetoothCLI = BluetoothCLI()
        while true {
            // print("\n--- IQOS CLI ---")
            // print("1: Start Scanning")
            // print("2: Stop Scanning")
            // print("3: Connect to Device")
            // print("0: Exit\n")

            // print("command> ", terminator: "")

            bluetoothCLI.run()
        }
    }
}

	
