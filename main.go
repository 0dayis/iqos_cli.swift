package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"tinygo.org/x/bluetooth"
)

var adapter = bluetooth.DefaultAdapter

func main() {
	// Enable BLE interface.
	must("enable BLE stack", adapter.Enable())

	// Start scanning.
	println("scanning...")
	err := adapter.Scan(func(adapter *bluetooth.Adapter, device bluetooth.ScanResult) {
		if strings.Contains(device.LocalName(), "IQOS") {
			fmt.Println("\nFound IQOS device: ", device.Address.String())
			// println(device.Address.String())
			reader := bufio.NewReader(os.Stdin)
			println("[] Do you want to connect to this device? (y/n)")
			key, err := reader.ReadString('\n')
			if err != nil {
				panic(err)
			}
			if key == "yes" || key == "y" {
				adapter.Connect(device.Address, bluetooth.ConnectionParams{})
			}
		}
		// println("found device:", device.Address.String(), device.RSSI, device.LocalName())
	})
	must("start scan", err)
}

func must(action string, err error) {
	if err != nil {
		panic("failed to " + action + ": " + err.Error())
	}
}
