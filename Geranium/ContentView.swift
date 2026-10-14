//
//  ContentView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct ContentView: View {
    @State var defaultTab = AppSettings().defaultTab
    var body: some View {
        TabView(selection: $defaultTab) {
            HomeView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
                .tag(1)
            DaemonView()
                .tabItem {
                    Label("守护进程", systemImage: "flag.fill")
                }
                .tag(2)
                .onAppear {
                    RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                }
            LocSimView()
                .tabItem {
                    Label("虚拟定位", systemImage: "mappin")
                }
                .tag(3)
            CleanerView()
                .tabItem {
                    Label("清理", systemImage: "trash.fill")
                }
                .tag(4)
            SuperviseView()
                .tabItem {
                    Label("监管", systemImage: "checkmark.seal.fill")
                }
                .tag(5)
        }
        .tint(.indigo)
    }
}
