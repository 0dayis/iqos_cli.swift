import Foundation
import ArgumentParser

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
