// The Swift Programming Language
// https://docs.swift.org/swift-book

func main() {
    print("Scanning...\\")
    print("Do you want to connect to this device? (y/n): ", terminator: "")
    let str = readLine(strippingNewline: true)!
    switch str {
    case "yes", "y":
        print("IQOS")
    case "no", "n":
        print("IQOS CLI")
    default:
        return
    }
}

main()
