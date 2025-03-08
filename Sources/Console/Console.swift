import Foundation
import ArgumentParser

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