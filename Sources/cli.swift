
struct Cli {
    let arguments: [String]

    init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    func view_menu(title: String, inputLabel: String, child: String) {
        print("\n--- \(title) ---")
        print(child)
        print("\(inputLabel)> ", terminator: "")
    }

    func run() {
        print("Hello, world!")
    }
}