import Foundation
import SwiftTUI

struct Dashboard: View {
    enum DisplayKind {
        case boot
        case main
    }
    private var title: String
    @State var displayKind: DisplayKind

    var boot: BootContent = BootContent()
    var main: MainContent = MainContent()

    init(
        title: String
        ) {
        self.title = title
        self.displayKind = .boot
    }

    var body: some View {
        VStack {
            Text(title)
            VStack {
                switch displayKind {
                case .boot:
                    boot
                case .main:
                    main
                }
            }
        }
    }
}

struct Message: Identifiable, View {
    var id = UUID()
    var text: String
    var body: some View {
        Text(text)
    }
}

struct BootContent: View {
    @State private var msgs: [Message] = [
        Message(text: "Welcome to IQOS CLI")
    ]
    var body: some View {
        ForEach(msgs) { msg in
            msg
        }
    }

    var addMsg: (Message) -> Void {
        { msg in
            msgs.append(msg)
        }
    }
}

struct MainContent: View {
    var body: some View {
        VStack {
            Text("IQOS CLI")
            VStack {
                Text("Model Number: ")
                Text("Manufacturer N")
                Text("Serial Number:)")
                Text("Charger Batter)")
            }
        }
    }
}