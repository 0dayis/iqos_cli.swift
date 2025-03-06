import Foundation
import CoreBluetooth

class IQOS: NSObject {
    var modelNumber: String = ""
    var customeName: String = ""
    var serialNumber: String = ""
    var softwareRevision: String = ""
    var manufacturerName: String = ""
    var chargerBatteryState: UInt8 = 0
    var scpCharacteristicUUID: CBUUID?
    var peripheral: CBPeripheral?

    // characteristics
    var scp_chara: CBCharacteristic?
    var battery_chara: CBCharacteristic?


    func setChargerBattery(characteristic: CBCharacteristic) {
        chargerBatteryState = characteristic.value![2]
    }

    func reloadBatteryState() {
        peripheral?.readValue(for: battery_chara!)
    }

    func initFromCharacteristic(characteristic: CBCharacteristic) {
        switch "\(characteristic.uuid)"
        {
            case "Model Number String":
                modelNumber = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            case "Serial Number String" :
                serialNumber = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            case "Software Revision String":
                softwareRevision = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            case "Manufacturer Name String":
                manufacturerName = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            // for charger battery capacity
            case "F8A54120-B041-11E4-9BE7-0002A5D5C51B":
                // example
                // ["0f", "00", "4b", "18", "54", "0f", "64"]
                //               ↑ indicate battery level

                battery_chara = characteristic
                setChargerBattery(characteristic: characteristic)
                peripheral?.setNotifyValue(true, for: battery_chara!)
            case "E16C6E20-B041-11E4-A4C3-0002A5D5C51B":
                scp_chara = characteristic
                peripheral?.setNotifyValue(true, for: scp_chara!)
                if scp_chara?.isNotifying == true {
                    print("SCP is notifying")
                }
            default:
                break
        }
    }

    func sendConfirmation() {
        let signal: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
        peripheral?.writeValue(signal, for: scp_chara!, type: .withResponse)
    }

    func viberation() {
        let payload: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x01, 0x1e, 0x00, 0x00, 0xc3])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func stopViberation() {
        let payload: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x00, 0x1e, 0x00, 0x00, 0xd5])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func lock() {
        let signals: [Data] = [
            Data([0x00, 0xc9, 0x44, 0x04, 0x02, 0xff, 0x00, 0x00, 0x5a]),
            Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
        ]
        signals.forEach { signal in
            peripheral?.writeValue(signal, for: scp_chara!, type: .withResponse)
        }
        sendConfirmation()
    }

    func unlock() {
        let signals: [Data] = [
            Data([0x00, 0xc9, 0x44, 0x04, 0x00, 0x00, 0x00, 0x00, 0x5d]),
            Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
        ]
        signals.forEach { signal in
            peripheral?.writeValue(signal, for: scp_chara!, type: .withResponse)
        }
        sendConfirmation()
    }
}

class IQOSIlumaI: IQOS {
    func enableFlexpuff() {
        let payload: Data = Data([0x00, 0xd2, 0x45, 0x22, 0x03, 0x01, 0x00, 0x00, 0x0A])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func disableFlexpuff() {
        let payload: Data = Data([0x00, 0xd2, 0x45, 0x22, 0x03, 0x00, 0x00, 0x00, 0x0A])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
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
        let first: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
        let second: Data = Data([0x00, 0xc0, 0x02, 0x23, 0xc3])
        let third: Data = Data([0x00, 0xc9, 0x44, 0x24, 0x64, 0x00, 0x00, 0x00, 0x34])
        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
    }

    func toBrightnessLow() {
        // let payload: Data = Data([0x00, 0x08, 0x84, 0x24, 0x1e, 0x00, 0x00, 0x00, 0x00])
        let first: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x1e, 0x00, 0x00, 0x00, 0xe1])
        let second: Data = Data([0x00, 0xc0, 0x02, 0x23, 0xc3])
        let third: Data = Data([0x00, 0xc9, 0x44, 0x24, 0x1e, 0x00, 0x00, 0x00, 0x9a])
        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
    }

    func enableAutostart() {
        let payload = Data([0x00, 0xc9, 0x47, 0x24, 0x01, 0x01, 0x00, 0x00, 0x3f])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func disableAutostart() {
        let payload = Data([0x00, 0xc9, 0x47, 0x24, 0x01, 0x00, 0x00, 0x00, 0x54])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func enableSmartgesture() {
        let first: Data = Data([0x00, 0xc9, 0x48, 0x05, 0x3c, 0x05, 0x01, 0x00, 0x00, 0x01, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xc0])
        let second: Data = Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3])
        let third: Data = Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])

        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
    }

    func disableSmartgesture() {
        // 21:47:70100
        let first: Data = Data([0x00, 0xc9, 0x48, 0x05, 0x2f, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xeb])
        let second: Data = Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3])
        let third: Data = Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])

        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
        // peripheral.writeValue(payload, for: characteristic, type: .withResponse)
    }

    func test() {
        let signal: Data = Data([0x00, 0xc9, 0x10, 0x02, 0x00, 0x02, 0xb9, 0xa5])
        peripheral?.writeValue(signal, for: scp_chara!, type: .withResponse)
    }
}