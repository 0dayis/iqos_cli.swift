//
//  Test.swift
//  iqos_cli
//
//  Created by Jukan Kyokou on 26/02/2025.
//

import Foundation
import Testing
import IOBluetooth

class HCI {
    func pairedDevices() {
        print("Bluetooth devices:")
        guard let devices = IOBluetoothDevice.pairedDevices() else {
            print("No devices")
            return
        }
        for item in devices {
            if let device = item as? IOBluetoothDevice {
                print("Name: \(device.name)")
                print("Paired?: \(device.isPaired())")
                print("Connected?: \(device.isConnected())")
            }
        }
    }

    func sendLEReadRemoteFeatures(device: IOBluetoothDevice) {
        guard let pointer = device.getDeviceRef() else { return }
        
        // LE Read Remote Features Command
        let cmd: [UInt8] = [
            0x16, 0x20,  // Opcode: 0x2016 (LE Read Remote Features)
            0x02,        // Parameter Length
            0x45, 0x00   // Connection Handle: 0x0045
        ]
        
        // HCIRequestCreate を使用してコマンドを送信
        var request: IOBluetoothHCIRequest?
        let result = IOBluetoothHCIRequestCreate(&request)
        
        if result == kIOReturnSuccess {
            request?.commandOpCode = 0x2016
            request?.commandParameters = cmd
            request?.send()
        }
    }
}

struct Test {

    @Test func TestHCI() async throws {
        var bt = HCI()
        bt.pairedDevices()
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    }

}
