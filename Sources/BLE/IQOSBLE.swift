import Foundation
import CoreBluetooth

class IQOSBLE {
    var modelNumber: String = ""
    var serialNumber: String = ""
    var softwareRevision: String = ""
    var manufacturerName: String = ""
    var chargerBatteryState: UInt8 = 0
    var scpCharacteristicUUID: CBUUID?
    var peripheral: CBPeripheral?
    var register: String = ""

    // characteristics
    var scp_chara: CBCharacteristic?
    var battery_chara: CBCharacteristic?

    private func setChargerBattery(characteristic: CBCharacteristic) {
        chargerBatteryState = characteristic.value![2]
    }

    func reloadBatteryState() {
        peripheral?.readValue(for: battery_chara!)
    }

    func from<T: CBCharacteristic>(characteristic: T) {
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
}
