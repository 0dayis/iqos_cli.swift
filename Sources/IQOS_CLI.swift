// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

@main
struct IqosCli {
    static func main() {
        let bluetoothCLI = BluetoothCLI()
        while true {
            print("\n--- IQOS CLI ---")
            print("1: Start Scanning")
            print("2: Stop Scanning")
            print("3: Connect to Device")
            print("0: Exit\n")

            print("command> ", terminator: "")

            if let input = readLine() {
                switch input {
                case "1":
                    bluetoothCLI.run()
                case "2":
                    bluetoothCLI.stopScan()
                case "3":
                    print("Enter device name to connect: ", terminator: "")
                    if let deviceName = readLine() {
                        bluetoothCLI.connectToDevice(named: deviceName)
                    }
                case "0":
                    print("Exiting...")
                    exit(0)
                default:
                    print("Invalid command.")
                }
            }
        }
    }
    func run() {
        print("Bluetooth CLI running...")
    }
}

	
