import Foundation
import ArgumentParser

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

    struct Flexpuff: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "flexpuff",
            abstract: "Control the flexpuff"
        )

        enum FlexpuffKind: String, ExpressibleByArgument {
            case enable 
            case disable
        }

        @Argument(help: "enable or disable flexpuff")
        var kind: FlexpuffKind?

        mutating func run(iqos: IQOSIlumaI) {
            if let kind = kind {
                switch kind {
                    case .enable:
                        iqos.enableFlexpuff()
                        print("Setting flexpuff to enable")
                    case .disable:
                        iqos.disableFlexpuff()
                        print("Setting flexpuff to disable")
                }
            } else {
                print("Please specify a flexpuff kind")
            }
        }
    }

    struct FindMyIQOS: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "findmyiqos",
            abstract: "Find my IQOS"
        )

        @Argument(help: "Stop finding my IQOS")
        var stop: String?

        @Option(name: .shortAndLong, help: "Interval in seconds")
        var interval: Int?

        mutating func run(iqos: IQOS) {
            if let stop = stop {
                if stop == "stop" {
                        iqos.stopViberation()
                        print("Stop finding my IQOS")
                }
            } else {
                print("Finding my IQOS...")
                iqos.viberation()
                if let interval = interval {
                    sleep(UInt32(interval))
                    iqos.stopViberation()
                    print("Stop finding my IQOS")
                }
            }
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

    struct Autostart: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "autostart",
            abstract: "Control the autostart"
        )

        enum AutostartKind: String, ExpressibleByArgument {
            case enable 
            case disable
        }

        @Argument(help: "On or off autostart")
        var kind: AutostartKind?

        mutating func run(iqos: IQOSIlumaI) {
            if let kind = kind {
                switch kind {
                    case .enable:
                        iqos.enableAutostart()
                        print("Setting autostart to enable")
                    case .disable:
                        iqos.disableAutostart()
                        print("Setting autostart to disable")
                }
            } else {
                print("Please specify a autostart kind")
            }
        }
    }

    struct SmartgestureCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "smartgesture",
            abstract: "Control the smartgesture"
        )

        enum SmartgestureKind: String, ExpressibleByArgument {
            case enable 
            case disable
        }

        @Argument(help: "On or off smartgesture")
        var kind: SmartgestureKind?

        mutating func run(iqos: IQOSIlumaI) {
            if let kind = kind {
                switch kind {
                    case .enable:
                        iqos.enableSmartgesture()
                        print("Setting smartgesture to enable")
                    case .disable:
                        iqos.disableSmartgesture()
                        print("Setting smartgesture to disable")
                }
            } else {
                print("Please specify a smartgesture kind")
            }
        }
    }
}

struct IQOSCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "iqos",
        abstract: "IQOS CLI",
        subcommands: [
            BatteryCommand.self,
            BrightnessCommand.self,
            SmartgestureCommand.self,
            FindMyIQOS.self,
            Autostart.self,
            Flexpuff.self
        ]
    )
}

struct Console {
    func run() {
        let ble = BluetoothCLI()
        ble.run()
        ble.onDone = {
            while true {
                print("iqos> ", terminator: "")
                fflush(stdout)
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
                        case var com as IQOSCommand.SmartgestureCommand:
                            com.run(iqos: ble.iqosIlumaI)
                        case var com as IQOSCommand.FindMyIQOS:
                            com.run(iqos: ble.iqosIlumaI)
                        case var com as IQOSCommand.Autostart:
                            com.run(iqos: ble.iqosIlumaI)
                        case var com as IQOSCommand.Flexpuff:
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