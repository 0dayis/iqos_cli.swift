import CoreBluetooth
import Foundation

class BluetoothCLI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var connectedIqos: CBPeripheral?
    private var iqos: IQOS?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        print("Scanning...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
        print("Stopped scan.")
    }
    
    func connectToDevice(named deviceName: String) {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for \(deviceName)...")
        discoveredPeripheral = nil  // Ensure no previous device is retained
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }

        // Don't continue if we're already scanning
        guard central.isScanning == false else { return }

        startScan()
	}

	func centralManager(
		_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
		advertisementData: [String: Any], rssi RSSI: NSNumber
	) {

		if let name = peripheral.name, name.starts(with: "IQOS") {
			print("Found target device \(name), connecting...")
			discoveredPeripheral = peripheral
			centralManager.stopScan()
			centralManager.connect(peripheral, options: nil)
		}
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("Connected to \(peripheral.name ?? "Unknown")")
		peripheral.delegate = self
        self.connectedIqos = peripheral
        self.iqos = IQOS(name: peripheral.name ?? "Unknown")
		peripheral.discoverServices(nil)
        // peripheral.discoverServices([CBUUID(string: "1bc5d5a5-0200-459e-e411-41b0-40b2ebda")])
        // peripheral.discoverServices([CBUUID(string: "Client Characteristic Configuration")])
        // peripheral.discoverServices([CBUUID(string: "1800")])
	}

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
        return
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { print("Unable to discover services:"); return }
        for service in services {
            // serviceのUUIDは種類を示す
            print("Service: \(service.uuid)")
            // handleは抽象化されている
            print("UUID String \(service.uuid.uuidString)")
            print("ancs: \(peripheral.state)")
            print("summary: \(peripheral.canSendWriteWithoutResponse)")
            // print("service description \(service.description)")
            peripheral.discoverIncludedServices(nil, for: service)
            // if service.uuid == CBUUID(string: "DAEBB240-B041-11E4-9E45-0002A5D5C51B") {
            // if service.uuid.uuidString == "180A" {
            //     peripheral.discoverCharacteristics(nil, for: service)
            // }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        guard let includedServices = service.includedServices else { print("Unable to discover included services:"); return }
        for includedService in includedServices {
            print("Discovered included service \(includedService.uuid)")
        }
        if let error = error {
        print("セカンダリサービス探索失敗: \(error.localizedDescription)")
        return
        }

        guard let includedServices = service.includedServices else {
            print("サービス \(service.uuid) にセカンダリサービスはありません。")
            return
        }

        for includedService in includedServices {
            print("セカンダリサービス発見: \(includedService.uuid)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { print("Unable to discover characteristics:"); return }
        for characteristic in characteristics {
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        // guard let descriptors = characteristic.descriptors else { print("Unable to discover descriptors:"); return }
        // for descriptor in descriptors {
        //     // print("Discovered descriptor \(descriptor.uuid)")
            // print("Discovered descriptor \(descriptor.value ?? "nil")")
            // print("Discovered descriptor \(descriptor.description)")
        // }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch "\(characteristic.uuid)"
        {
            case "Model Number String":
                self.iqos?.modelNumber = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            // for charger battery capacity
            case "F8A54120-B041-11E4-9BE7-0002A5D5C51B":
                // example
                // ["0f", "00", "4b", "18", "54", "0f", "64"]
                //               ↑ indicate battery level

                if let batteryCap = characteristic.value?[2] {
                    self.iqos?.chargerBatteryCapacity = batteryCap
                }
                print("battery: ", self.iqos?.chargerBatteryCapacity ?? "nil")

            case "E16C6E20-B041-11E4-A4C3-0002A5D5C51B":
                let first: Data = Data([0x00, 0xc0, 0x01, 0x21, 0xf2])
                let second: Data = Data([0x00, 0xc0, 0x00, 0x00, 0x01, 0x07])
                let third: Data = Data([0x00, 0xc0, 0x04, 0x06, 0x01, 0x00, 0x00, 0x00, 0xf9])
                let fourth: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
                let fifth: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
                print("writing to \(characteristic.uuid)...")
                peripheral.writeValue(first, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                peripheral.writeValue(second, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                peripheral.writeValue(third, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                peripheral.writeValue(fourth, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                peripheral.writeValue(fifth, for: characteristic, type: CBCharacteristicWriteType.withResponse)

            default:
                print("Unknown characteristic \(characteristic.uuid)")
        }
        print("Updated value for characteristic \(characteristic.uuid)")
        print("value: ", characteristic.value ?? "nil")
        print("properties: ", characteristic.properties) 
        print("can send write without response: ", peripheral.canSendWriteWithoutResponse)
        // print("descryptor",  peripheral.discoverDescriptors(for: characteristic))
        // print("enc", characteristic.properties.contains(.write))
        print("desscription", characteristic.description)
        print("binary value: ", characteristic.value?.map { String(format: "%02hhx", $0) } ?? "nil")
        print("string value: ", String(decoding: characteristic.value ?? Data(), as: UTF8.self) ?? "nil", "\n")
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write value for \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        print("Successfully wrote value for \(characteristic.uuid)")
    }

    func run() {
        RunLoop.main.run()
    }
    
}