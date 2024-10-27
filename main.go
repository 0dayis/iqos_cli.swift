package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"time"

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
			print("[] Do you want to connect to this device? (y/n): ")
			scanner := bufio.NewScanner(os.Stdin)
			scanner.Scan()
			input := scanner.Text()

			switch input {
			case "", "yes", "y":
				adapter.StopScan()
				println("Connecting to device: ", device.Address.String())
				conn, err := adapter.Connect(device.Address, bluetooth.ConnectionParams{})
				if err != nil {
					panic(err)
				}
				println("Connected to device: ", device.Address.String())
				sr, err := conn.DiscoverServices([]bluetooth.UUID{bluetooth.ServiceUUIDSMP})
				must("discover services", err)
				fmt.Printf("%v", sr)

			case "no", "n":
				return

			default:
				println("Invalid input")
			}
		}
		// println("found device:", device.Address.String(), device.RSSI, device.LocalName())
	})
	time.Sleep(10 * time.Second)
	must("start scan", err)
}

func must(action string, err error) {
	if err != nil {
		panic("failed to " + action + ": " + err.Error())
	}
}
