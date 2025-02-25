import Foundation

class IQOS: NSObject {
    private var name: String
    var modelNumber: String? = ""
    var serialNumber: String? = ""
    var softwareRevision: String? = ""
    var manufacturerName: String? = ""
    var chargerBatteryCapacity: UInt8 = 0

    init(
        name: String
    ) {
        self.name = name
    }

    // build(from ) {}
    func run() {
        print("Hello, world!")
    }
}