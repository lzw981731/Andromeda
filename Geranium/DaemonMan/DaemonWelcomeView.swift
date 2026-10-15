//
//  DaemonWelcomeView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct DaemonWelcomeView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List {
            
            Section(header: Text("用途")) {
                Text("通过向 iOS 内部添加规则，本软件可阻止守护进程在手机启动时运行。应用会列出所有正在运行的守护进程，左滑即可移除。")
            }
            
            Section(header: Text("警告")) {
                Text("禁用系统守护进程有风险，可能导致设备无限重启。请谨慎操作，设备出现任何问题本人概不负责。")
                    .foregroundStyle(.red)
            }
            Section(header: Text("请注意")) {
                Text("如果想撤销某项选择，请进入管理器（应用图标旁的列表图标），在那里可以切换已禁用的守护进程。")
                    .foregroundStyle(.green)
            }
            Section(header: Text("更多信息")) {
                Button("守护进程列表及其作用") {
                    UIApplication.shared.open(URL(string: "https://www.reddit.com/r/jailbreak/comments/10v7j59/tutorial_list_of_ios_daemons_and_what_they_do/")!)
                }
                Button("可禁用的守护进程列表") {
                    UIApplication.shared.open(URL(string: "https://www.reddit.com/r/jailbreak/comments/10v7j59/comment/j8s1lgj/")!)
                }
            }
        }
        .navigationTitle("注意")
        .navigationBarItems(trailing: Button("明白了") {
            close()
        })
        .environment(\.defaultMinListRowHeight, 50)
        .interactiveDismissDisabled()
    }

    func close() {
        dismiss()
    }
}

#Preview {
    DaemonWelcomeView()
}
