//
//  WelcomeView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//


import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var loggingAllowed: Bool
    @Binding var updBypass: Bool
    @StateObject private var appSettings = AppSettings()
    var body: some View {
        List {
            Section(header: Text("初始设置")) {
                Text("Welcome to Andromeda, a powerful iOS toolbox for TrollStore. Simulate your location with joystick & routes, manage daemons, clean storage with detailed reports, and more. Developed by son3ra1n.")
            }
            if getDeviceCode() == "iPhone8,4" {
                Section(header: Text("嗨！SE 1 用户")) {
                    Text("It looks like you are using the app on an iPhone SE 2016 (1st gen). You might encounter serious UI issues. Please excuse me in advance.")
                }
            }
            Section(header: Text("日志收集")) {
                Text("We collect some logs that are uploaded to our server for fixing bugs and adressing crash logs. The logs never contains any of your personal information, just your device type and the crash log itself. We also collect measurement information to see what was the most used in the app. You can choose if you want to prevent ANY data from being sent to our server.")
                Toggle(isOn: $loggingAllowed) {
                    Text("开启日志收集")
                }
                .onChange(of: loggingAllowed) { newValue in
                    if !loggingAllowed {
                        UIApplication.shared.alert(title: "警告", body: "Disabling logging might make things more difficult for developers if you have an issue.")
                    }
                }
            }
            
            Section(header: Text("更新提醒")) {
                Text("When a new update is published, you will receive a pop-up on app launch asking you if you want to update. You can prevent this from hapenning")
                Toggle(isOn: $updBypass) {
                    Text("关闭更新弹窗")
                }
            }
            
            Section(header: Text("清理文件大小")) {
                Text("This is an issue that might incorrectly set permissions when calculating file sizes for your device.")
                Toggle(isOn: $appSettings.getSizes) {
                    Text("计算文件大小")
                }
            }
            if !updBypass {
                Section(header: Text("警告")) {
                    Text("If you want to enable auto-update, you need to turn on Magnifier URL Scheme in TrollStore.")
                    Text("1. 打开 TrollStore")
                    Text("2. 前往“设置”")
                    Text("3. 开启 URL Scheme")
                }
            }
        }
        .navigationTitle("欢迎！")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("忽略") {
                    close()
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 50)
        .interactiveDismissDisabled()
    }

    func close() {
        dismiss()
    }
}

public struct CustomButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                            .fill(Color.accentColor))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct LinkButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(Color.blue.opacity(0.1)))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct DangerButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 12)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(Color.red.opacity(0.1)))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
