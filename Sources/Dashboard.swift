import Foundation
import ArgumentParser


extension IQOSCommand {
    struct BatteryCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "battery",
            abstract: "Show or manipulate battery information"
        )

        @Argument(help: "The battery level")
        var level: Int?
        
        @Flag(name: .shortAndLong, help: "Show detailed battery info")
        var detailed: Bool = false
        
        func run() {
            print("Battery level: \(level ?? 85)%")
            print("Battery: 85%")
        }
    }

    struct BrightnessCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "brightness",
            abstract: "Control the LED brightness"
        )
        
        @Argument(help: "Brightness level (0-100)")
        var level: Int?
        
        func run() {
            if let level = level {
                if level < 0 || level > 100 {
                    print("Error: Brightness must be between 0 and 100")
                } else {
                    print("Setting brightness to \(level)%")
                }
            } else {
                print("Current brightness: 50%")
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
        while true {
            print("iqos> ", terminator: "")
            guard let input = readLine() else { continue }

            if input == "quit" || input == "exit" {
                print("Goodbye!")
                break
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
                        com.run()
                    case var com as IQOSCommand.BrightnessCommand:
                        com.run()
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
}