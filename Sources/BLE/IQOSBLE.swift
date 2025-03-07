import Foundation
import CoreBluetooth

protocol IQOSBLEProtocol {
    var peripheral: CBPeripheral? { get set }
    var scp_chara: CBCharacteristic? { get set }
    var battery_chara: CBCharacteristic? { get set }
    
    // 共通のシグナルなど
    var confirmationSignal: Data { get }
    var startViberationSignal: Data { get }
    var stopViberationSignal: Data { get }
    var lockSignals: [Data] { get }
    var unlockSignals: [Data] { get }
    // 他の必要なプロパティやメソッド
}

class IQOSBLE: IQOSBLEProtocol {
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

    // signals for basic IQOS
    public let confirmationSignal: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
    public let startViberationSignal: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x01, 0x1e, 0x00, 0x00, 0xc3])
    public let stopViberationSignal: Data = Data([0x00, 0xc0, 0x45, 0x22, 0x00, 0x1e, 0x00, 0x00, 0xd5])
    public let lockSignals: [Data] = [
        Data([0x00, 0xc9, 0x44, 0x04, 0x02, 0xff, 0x00, 0x00, 0x5a]),
        Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
    ]
    public let unlockSignals: [Data] = [
        Data([0x00, 0xc9, 0x44, 0x04, 0x00, 0x00, 0x00, 0x00, 0x5d]),
        Data([0x00, 0xc9, 0x00, 0x04, 0x1c])
    ]


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
}
