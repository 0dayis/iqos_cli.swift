import Foundation

class IQOS: NSObject {
    private var name: String
    private var modelNumber: String?
    private var serialNumber: String?
    private var softwareRevision: String?
    private var manufacturerName: String?
    private var chargerBatteryCapacity: Int?

    init(
        name: String
    ) {
        self.name = name
    }
    func run() {
        print("Hello, world!")
    }
}