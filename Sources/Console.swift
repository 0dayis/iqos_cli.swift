import Foundation
import ArgumentParser

// struct Cli {
//     let arguments: [String]
//     let ble = BluetoothCLI()

//     init(arguments: [String] = CommandLine.arguments) {
//         self.arguments = arguments
//     }

//     func view_prompt(title: String, inputLabel: String, child: String) {
//         print("\n--- \(title) ---")
//         print(child)
//         print("\(inputLabel)> ", terminator: "")
//     }

//     func run() {
//         let console = Console()
//         console.run()
//         // ble.onDone = {
//         //     // print(ble.iqosIlumaI)
//         //     // ble.iqosIlumaI.view()
//         // }
//     }
// }
extension IQOSCommand {
    struct BatteryCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "battery",
            abstract: "Show or manipulate battery information"
        )

        // @Argument(help: "The battery level")
        // var level: Int?
        
        // @Flag(name: .shortAndLong, help: "Show detailed battery info")
        // var detailed: Bool = false
        
        mutating func run(iqos: IQOS) {
            iqos.reloadBatteryState()
            print("Battery: \(iqos.chargerBatteryState)%")
        }
    }

    struct BrightnessCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "brightness",
            abstract: "Control the LED brightness"
        )

        enum BrightnessLevel: String, ExpressibleByArgument {
            case low = "low"
            case high = "high"
        }
        
        @Argument(help: "High or low brightness")
        var level: BrightnessLevel?
        
        mutating func run(iqos: IQOSIlumaI) {
            if let level = level {
                switch level {
                    case .low:
                        iqos.toBrightnessLow()
                        print("Setting brightness to low")
                    case .high:
                        iqos.toBrightnessHigh()
                        print("Setting brightness to high")
                }
            } else {
                print("Please specify a brightness level")
            }
        }
    }
}
struct IQOSCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iqos",
        abstract: "IQOS CLI",
        subcommands: [BatteryCommand.self, BrightnessCommand.self]
    )
}

struct Console {
    func run() {
        let ble = BluetoothCLI()
        ble.run()
        ble.onDone = {
            while true {
                print("iqos> ", terminator: "")
                guard let input = readLine() else { continue }

                if input == "quit" || input == "exit" {
                    print("Goodbye!")
                    return
                }

                if input == "help" {
                    print("Available commands: battery, brightness, quit")
                    continue
                }

                let args = input.split(separator: " ").map(String.init)

                do {
                    let command = try IQOSCommand.parseAsRoot(args)
                    switch command {
                        case var com as IQOSCommand.BatteryCommand:
                            com.run(iqos: ble.iqosIlumaI)
                        case var com as IQOSCommand.BrightnessCommand:
                            com.run(iqos: ble.iqosIlumaI)
                        default:
                            print("Unknown command")
                    }
                } catch {
                    print("Error: \(error)")

                    if let parseError = error as? ValidationError {
                        print(parseError.message)
                    }
                }
            }
        }
        RunLoop.main.run()
    }
}