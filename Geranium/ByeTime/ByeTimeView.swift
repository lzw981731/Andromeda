//
//  ByeTimeView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct ByeTimeView: View {
    @Binding var DebugStuff: Bool
    @State var ScreenTimeAgent: Bool = true
    @State var usagetrackingd: Bool = true
    @State var homed: Bool = false
    @State var familycircled: Bool = false
    var body: some View {
        VStack {
            List {
                Section(header: Label("Screen Time Agent", systemImage: "hourglass"), footer: Text("Screen Time Agent 负责管理所有屏幕使用时间偏好设置。仅禁用该进程最多只能部分禁用屏幕使用时间。")) {
                    Toggle(isOn: $ScreenTimeAgent) {
                        Text("禁用屏幕使用时间代理")
                    }
                    .disabled(!DebugStuff)
                }
                Section(header: Label("Usage Tracking Agent", systemImage: "magnifyingglass"), footer: Text("Usage Tracking Agent 负责监控和上报由健康、家长控制（=屏幕使用时间）或设备管理设置的使用额度。禁用它可能还会禁用 iPhone 上的其他功能。")) {
                    Toggle(isOn: $usagetrackingd) {
                        Text("禁用使用情况跟踪代理")
                    }
                }
                Section(header: Label("Homed", systemImage: "homekit"), footer: Text("Homed 负责 HomeKit 配件和产品，例如你在手机“家庭”应用中管理的 HomePod、智能灯泡等。如果你在使用这些配件，请勿禁用。")) {
                    Toggle(isOn: $homed) {
                        Text("禁用 Homed")
                    }
                }
                Section(header: Label("Familycircled", systemImage: "figure.and.child.holdinghands"), footer: Text("Familycircled 负责 iCloud 家人共享系统，包括家人订阅，禁用后将无法使用。但这有助于阻止屏幕使用时间工作。")) {
                    Toggle(isOn: $familycircled) {
                        Text("禁用 Familycircled")
                    }
                }
            }
            Button("再见，屏幕使用时间！", action : {
                UIApplication.shared.confirmAlert(title: "你即将禁用这些守护进程。", body: "这将删除屏幕使用时间偏好设置文件，并阻止以下守护进程随 iOS 启动。确定要继续吗？", onOK: {
                    UIApplication.shared.alert(title: "正在移除屏幕使用时间…", body: "设备将会重启，建议首次自动重启后再手动重启一次。", animated: false, withButton: false)
                    DisableScreenTime(screentimeagentd: ScreenTimeAgent, usagetrackingd: usagetrackingd, homed: homed, familycircled: familycircled)
                }, noCancel: false, yes: true)
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.black)
            Button("启用屏幕使用时间", action : {
                UIApplication.shared.confirmAlert(title: "你即将重新启用屏幕使用时间。", body: "这将还原你做的所有屏幕使用时间备份，并重新开启日志记录。", onOK: {
                    enableBack()
                }, noCancel: false, yes: true)
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.black)
        }
    }
}
