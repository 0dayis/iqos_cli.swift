import Foundation
import CoreBluetooth

class IQOS: NSObject {
    var iqosble: IQOSBLE
    var register: String = ""

    // signals for basic IQOS
    private let confirmationSignal: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
    private let startViberationSignal: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x01, 0x1e, 0x00, 0x00, 0xc3])
    private let stopViberationSignal: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x00, 0x1e, 0x00, 0x00, 0xd5])
    private let lockSignals: [Data] = [
        Data([0x00, 0xc9, 0x44, 0x04, 0x02, 0xff, 0x00, 0x00, 0x5a]),
        Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
    ]
    private let unlockSignals: [Data] = [
        Data([0x00, 0xc9, 0x44, 0x04, 0x00, 0x00, 0x00, 0x00, 0x5d]),
        Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
    ]

    init(iqosble: IQOSBLE) {
        self.iqosble = iqosble
    }

    func batteryStatus() -> UInt8 {
        iqosble.peripheral?.readValue(for: iqosble.battery_chara!)
        return 9
    }

    func from<T: IQOSBLE>(iqosble: T) {
        self.iqosble = iqosble
    }

    func sendConfirmation() {
        iqosble.peripheral?.writeValue(confirmationSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func viberation() {
        iqosble.peripheral?.writeValue(startViberationSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func stopViberation() {
        iqosble.peripheral?.writeValue(stopViberationSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func lock() {
        lockSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
        sendConfirmation()
    }

    func unlock() {
        unlockSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
        sendConfirmation()
    }
}
