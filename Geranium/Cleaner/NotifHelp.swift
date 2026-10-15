//
//  NotifHelp.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct NotifHelp: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("问题"), footer: Text("你可能会丢失一些不重要的数据，例如 WiFi 密码和偏好设置。")) {
                    Text("清理后通知没了？别慌，解决方法在这里！")
                }
                Section(header: Text("操作步骤")) {
                    Text("首先打开“设置”，应用可以帮你打开。然后进入**通用**，下滑找到**还原**。")
                    Button("打开设置") {
                        if let url = URL(string:UIApplication.openSettingsURLString) {
                           if UIApplication.shared.canOpenURL(url) {
                              UIApplication.shared.open(url, options: [:], completionHandler: nil)
                           }
                        }
                    }
                }
                Section() {
                    Text("然后点按**还原**按钮（注意不是“抹掉所有内容和设置”）")
                }
                Section() {
                    Text("点按**还原所有设置**，按屏幕提示操作即可！")
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("更多帮助")
                        .font(.title2)
                        .bold()
                        .padding(.top, 10)
                }
            }

        }
        .environment(\.defaultMinListRowHeight, 50)
    }
}

#Preview {
    NotifHelp()
}
