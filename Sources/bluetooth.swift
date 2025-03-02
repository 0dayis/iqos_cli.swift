import CoreBluetooth
import Foundation

class BluetoothCLI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var discoveredCharacteristics: [CBCharacteristic] = []
    private var connectedIqos: CBPeripheral?
    var iqos: IQOS = IQOS()
    var iqosIlumaI: IQOSIlumaI = IQOSIlumaI()
    
    private var onConnected: (() -> Void)?
    private var onDiscovered: (() -> Void)?
    var onDone: (() -> Void)?
    
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

    func discover() {
        guard let peripheral = discoveredPeripheral else { return }
        peripheral.discoverServices(nil)
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
        self.iqos.peripheral = peripheral
        onConnected?()
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
            peripheral.discoverIncludedServices(nil, for: service)
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
            discoveredCharacteristics.append(characteristic)
        }
        onDiscovered?()
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
        if let error = error {
            print("Failed to read value for \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed to write value for \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        print("Successfully wrote value for \(characteristic.uuid)")
    }

    func run() {
        onConnected = {
            print("Gathering IQOS data...")
            self.discover()
            self.onDiscovered = {
                _ = self.discoveredCharacteristics.map { self.iqosIlumaI.build(characteristic: $0) }
                self.onDone?()
                // self.discoveredCharacteristics.forEach { characteristic in
                //     self.iqosIlumaI.build(characteristic: characteristic)
                // }
            }
        }
    }
    
}