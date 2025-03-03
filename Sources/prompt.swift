import Foundation

protocol CLIPrompt {
    func view(param: PromptParam)
}


struct Header {
    var title: String
    var menu: Menu
    var view: () -> Void

    func view() {
        print("\n--- \(title) ---")
    }
}

struct PromptParam {
    var title: String
    var promptLabel: String
    var child: [String]
    var quit
}

class Menu: NSObject, CLIPrompt {
    func listView(param: PromptParam) {
        for i in 0..<param.child.count {
            print("[\(i+1)]: \(param.child[i])")
        }
        print("[0]: Quit")
        print("\(param.promptLabel)> ", terminator: "")
        let command: String? = readLine()

    }
}