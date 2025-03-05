import CoreBluetooth
import Foundation

class Service {
    var cbService: CBService
    var isDiscovered: Bool = false
    var handler = { () -> Void in }

    init(cbService: CBService) {
        self.cbService = cbService
    }
}

class BluetoothCLI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    // private var boot = BootView()
    // var bootCon: BootContent
    // var mainCon: MainContent
    // var container: Dashboard<BootContent, MainContent>
    // var container: Dashboard<BootContent, MainContent>
    // var _: ContainerView<BootView> {
    //     ContainerView(title: "IQOS CLI") {
    //         view
    //     }
    // }

    var discoveredPeripheral: CBPeripheral?
    private var discoveredServices: [Service] = []
    var discoveredCharacteristics: [CBCharacteristic] = []

    private var connectedIqos: CBPeripheral?
    var iqos: IQOS = IQOS()
    var iqosIlumaI: IQOSIlumaI = IQOSIlumaI()
    
    // Handlers
    private var onConnected: (() -> Void)?
    private var onServicesDiscovered: (() -> Void)?
    private var onCharacteristicsDiscovered: (() -> Void)?
    private var onDiscoveredCharacteristics: (() -> Void)?
    private var onDiscovered: (() -> Void)?
    var onDone: (() -> Void)?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        // print("Scanning...")
        print("Scanning...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        centralManager.stopScan()
        // print("Stopped scan.")
        print("Stopped scan.")
    }

    func discoverServices(peripheral: CBPeripheral) {
        discoveredServices.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service.cbService)
            peripheral.discoverIncludedServices(nil, for: service.cbService)
        }
    }

    func discover() {
        iqosIlumaI.peripheral?.discoverServices(nil)

        onServicesDiscovered = {
            self.discoverServices(peripheral: self.iqosIlumaI.peripheral!)
            self.onCharacteristicsDiscovered = {
                self.onDiscovered?()
            }
        //     print("Discovered services: \(self.discoveredServices)")
        //     self.discoverServices(peripheral: peripheral)

        //     self.onDiscoveredCharacteristics = {
        //         print("Discovered characteristics: \(self.discoveredCharacteristics)")
        //         self.discoverCharacteristics(peripheral: peripheral)
        //         self.onDiscovered?()
        //     }
        }
    }
    
    func connectToDevice(named deviceName: String) {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        // print("Scanning for \(deviceName)...")
        print("Scanning for \(deviceName)...")
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
			// print("Found target device \(name), connecting...")
            print("Found target device \(name), connecting...")
            iqosIlumaI.peripheral = peripheral
            centralManager.stopScan()
			centralManager.connect(peripheral, options: nil)
		}
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		// print("Connected to \(peripheral.name ?? "Unknown")")
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
            let s =  Service(cbService: service)
            self.discoveredServices.append(s)
        }
        onServicesDiscovered?()
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
            discoveredServices.first(where: { $0.cbService == service })?.isDiscovered = true
        }

        if discoveredServices.allSatisfy({ $0.isDiscovered }) {
            onCharacteristicsDiscovered?()
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
            // print("Gathering IQOS data...")
            print("Gathering IQOS data...")
            self.discover()
            self.onDiscovered = {
                // _ = self.discoveredCharacteristics.map { self.iqosIlumaI.initFromCharacteristic(characteristic: $0) }
                self.discoveredCharacteristics.forEach { characteristic in
                    self.iqosIlumaI.initFromCharacteristic(characteristic: characteristic)
                }
                self.onDone?()
            }
        }
    }
    
}