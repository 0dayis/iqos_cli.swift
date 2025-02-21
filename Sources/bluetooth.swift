import CoreBluetooth
import Foundation

class BluetoothCLI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var connectedIqos: CBPeripheral?
    
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
		print("Connected to \(peripheral.name ?? "Unknown").")
		peripheral.delegate = self
        self.connectedIqos = peripheral
		peripheral.discoverServices(nil)
	}

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
        return
    }

    func run() {
        RunLoop.main.run()
    }
    
}
