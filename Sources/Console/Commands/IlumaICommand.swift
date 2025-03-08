import Foundation
import ArgumentParser

extension IQOSCommand {
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
            case test
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
                    case .test:
                        // iqos.test()
                        print("Testing")
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