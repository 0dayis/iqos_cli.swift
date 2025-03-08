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
                iqos.viberation()
                print("Press <Enter> key to stop")
                while true {
                    print("Finding> ", terminator: "")
                    fflush(stdout)
                    var input = readLine()
                    if input != nil {
                        iqos.stopViberation()
                        print("Found my IQOS")
                        break
                    } 
                }
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
            Flexpuff.self,
            Lock.self,
            UnLock.self
        ]
    )
}
