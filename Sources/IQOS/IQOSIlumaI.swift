import Foundation
import CoreBluetooth

class IQOSIlumaI: IQOS {

    // var iqosble: IQOSBLEProtocol
    private let enableFlexpuffSignal: Data = Data([0x00, 0xd2, 0x45, 0x22, 0x03, 0x01, 0x00, 0x00, 0x0A])
    private let disableFlexpuffSignal: Data = Data([0x00, 0xd2, 0x45, 0x22, 0x03, 0x00, 0x00, 0x00, 0x0A])
    private let brightnessHighSignals: [Data] = [
        Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f]),
        Data([0x00, 0xc0, 0x02, 0x23, 0xc3]),
        Data([0x00, 0xc9, 0x44, 0x24, 0x64, 0x00, 0x00, 0x00, 0x34])
    ]
    private let brightnessLowSignals: [Data] = [
        Data([0x00, 0xc0, 0x46, 0x23, 0x1e, 0x00, 0x00, 0x00, 0xe1]),
        Data([0x00, 0xc0, 0x02, 0x23, 0xc3]),
        Data([0x00, 0xc9, 0x44, 0x24, 0x1e, 0x00, 0x00, 0x00, 0x9a])
    ]
    private let enableAutostartSignal: Data = Data([0x00, 0xc9, 0x47, 0x24, 0x01, 0x01, 0x00, 0x00, 0x3f])
    private let disableAutostartSignal: Data = Data([0x00, 0xc9, 0x47, 0x24, 0x01, 0x00, 0x00, 0x00, 0x54])
    private let enableSmartgestureSignals: [Data] = [
        Data([0x00, 0xc9, 0x48, 0x05, 0x3c, 0x05, 0x01, 0x00, 0x00, 0x01, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xc0]),
        Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3]),
        Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])
    ]
    private let disableSmartgestureSignals: [Data] = [
        Data([0x00, 0xc9, 0x48, 0x05, 0x2f, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xeb]),
        Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3]),
        Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])
    ]

    private let testSig: Data = Data([0x00, 0xc9, 0x10, 0x02, 0x00, 0x02, 0xb9, 0xa5])

    func enableFlexpuff() {
        // iqosIlumaIble.peripheral?.writeValue(iqosIlumaIble.enableFlexpuffSig, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        iqosble.peripheral?.writeValue(enableFlexpuffSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func disableFlexpuff() {
        // iqosIlumaIble.peripheral?.writeValue(iqosIlumaIble.disableFlexpuffSig, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        iqosble.peripheral?.writeValue(disableFlexpuffSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func toBrightnessHigh() {
        // let first: Data = Data([0x00, 0xc0, 0x01, 0x21, 0xf2])
        // let second: Data = Data([0x00, 0xc0, 0x00, 0x00, 0x01, 0x07])
        // let third: Data = Data([0x00, 0xc0, 0x04, 0x06, 0x01, 0x00, 0x00, 0x00, 0xf9])
        // let fourth: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
        // let fifth: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
        // peripheral.writeValue(first, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(second, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(third, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(fourth, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(fifth, for: characteristic, type: CBCharacteristicWriteType.withResponse)

        // let payload: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
        // iqosIlumaIble.brightnessHighSigs.forEach { signal in
        //     iqosIlumaIble.peripheral?.writeValue(signal, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        // }
        brightnessHighSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
    }

    func toBrightnessLow() {
        // let payload: Data = Data([0x00, 0x08, 0x84, 0x24, 0x1e, 0x00, 0x00, 0x00, 0x00])
        // iqosIlumaIble.brightnessLowSigs.forEach { signal in
        //     iqosIlumaIble.peripheral?.writeValue(signal, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        // }
        brightnessLowSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
    }

    func enableAutostart() {
        // iqosIlumaIble.peripheral?.writeValue(iqosIlumaIble.enableAutostartSig, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        iqosble.peripheral?.writeValue(enableAutostartSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func disableAutostart() {
        // iqosIlumaIble.peripheral?.writeValue(iqosIlumaIble.disableAutostartSig, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        iqosble.peripheral?.writeValue(disableAutostartSignal, for: iqosble.scp_chara!, type: .withResponse)
    }

    func enableSmartgesture() {
        // iqosIlumaIble.enableSmartgestureSigs.forEach { signal in
        //     iqosIlumaIble.peripheral?.writeValue(signal, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        // }
        enableSmartgestureSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
    }

    func disableSmartgesture() {
        // iqosIlumaIble.disableSmartgestureSigs.forEach { signal in
        //     iqosIlumaIble.peripheral?.writeValue(signal, for: iqosIlumaIble.scp_chara!, type: .withResponse)
        // }
        disableSmartgestureSignals.forEach { signal in
            iqosble.peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)
        }
    }

    // func test() {
    //     let signal: Data = Data([0x00, 0xc9, 0x10, 0x02, 0x00, 0x02, 0xb9, 0xa5])
    //     peripheral?.writeValue(signal, for: iqosble.scp_chara!, type: .withResponse)

    //     sleep(UInt32(3))
    //     iqosble.peripheral?.readValue(for: scp_chara!)
    //     print("register: \(register)")
    //     // print("after sleep")
    //     // peripheral?.readValue(for: scp_chara!)
    // }
}