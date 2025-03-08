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
            print("Battery: \(iqos.batteryStatus())%")
        }
    }

    struct Lock: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "lock",
            abstract: "Lock the IQOS"
        )

        mutating func run(iqos: IQOS) {
            iqos.lock()
            print("Locked the IQOS")
        }
    }

    struct UnLock: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "unlock",
            abstract: "Unlock the IQOS"
        )

        mutating func run(iqos: IQOS) {
            iqos.unlock()
            print("Unlocked the IQOS")
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

}

struct Console {
    func run() {
        let ble = BLE()
        ble.run()
        ble.onDone = {
            var iqos: IQOSIlumaI = IQOSIlumaI(iqosble: ble.iqos)
            // iqos.from(iqosble: ble.iqosIlumaI)
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
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.BrightnessCommand:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.SmartgestureCommand:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.FindMyIQOS:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.Autostart:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.Flexpuff:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.Lock:
                            com.run(iqos: iqos)
                        case var com as IQOSCommand.UnLock:
                            com.run(iqos: iqos)
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