import Foundation

protocol CLIPrompt {
    func view(param: PromptParam)
}

struct PromptParam {
    var title: String
    var promptLabel: String
    var child: [String]
}

class Prompt: NSObject, CLIPrompt {
    func view(param: PromptParam) {
        print("\n--- \(param.title) ---")
        for i in 0..<param.child.count {
            print("[\(i+1)]: \(param.child[i])")
        }
        print("\(param.promptLabel)> ", terminator: "")
        let command: String? = readLine()

    }
}