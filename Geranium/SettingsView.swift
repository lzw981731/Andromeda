//
//  SettingsView.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI
import AlertKit

struct SettingsView: View {
    @State var defaultTab = AppSettings().defaultTab
    @State var DebugStuff: Bool = false
    @State var MinimCal: String = ""
    @State var LocSimTries: String = ""
    @State var localisation: String = {
        if langaugee != "" {
            return langaugee
        }
        else if let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languages.first {
                return "\(Locale.current.languageCode ?? "en-GB")"
        } else {
            return "en-GB"
        }
    }()
    @StateObject private var appSettings = AppSettings()
    
    // Custom language
    @State var appCodeLanguage = langaugee
    let languageMapping: [String: String] = [
                "zh-Hans": "简体中文",
                "zh-Hant": "繁体中文",
                "Base": "英语",
                "en-GB": "英语（英国）",
                "es": "西班牙语",
                "es-419": "西班牙语（拉丁美洲）",
                "fr": "法语",
                "it": "意大利语",
                "ja": "日语",
                "ko": "韩语",
                "ru": "俄语",
                "sk": "斯洛伐克语",
                "sv": "瑞典语",
                "tr": "土耳其语",
                "vi": "越南语",
    ]
    var sortedLocalisalist: [String] {
        languageMapping.keys.sorted()
    }
    
    // Open Tab
    let defaultTabList: [Int: String] = [
                1: "主页",
                2: "守护进程",
                3: "虚拟定位",
                4: "清理",
                5: "监管",
    ]
    
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - ByeTime Settings
                Section(header: Label("ByeTime", systemImage: "hourglass"), footer: Text("ByeTime 可彻底关闭屏幕使用时间，无论是否登录 iCloud。")) {
                    NavigationLink(destination: ByeTimeView(DebugStuff: $DebugStuff)) {
                        HStack {
                            Text("ByeTime 设置")
                        }
                    }
                }
                
                // MARK: - Language
                Section(header: Label("应用语言", systemImage: "magnifyingglass"), footer: Text("选择偏好语言，应用将退出以应用更改。")) {
                    Picker("语言", selection: $localisation) {
                        ForEach(sortedLocalisalist, id: \.self) { abbreviation in
                            Text(languageMapping[abbreviation] ?? abbreviation)
                                .tag(abbreviation)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: localisation) { newValue in
                        if localisation.contains("en-GB") || localisation.contains("zh") || localisation.contains("es-419"){
                            let parts = localisation.components(separatedBy: "-")
                            if let appCodeLanguage = parts.last {
                                appSettings.languageCode = appCodeLanguage
                                UserDefaults.standard.set(["\(localisation)"], forKey: "AppleLanguages")
                            }
                        }
                        else {
                            appSettings.languageCode = ""
                            UserDefaults.standard.set(["\(newValue)"], forKey: "AppleLanguages")
                        }
                        UIApplication.shared.confirmAlert(title: "需要重启", body: "应用需要重启以应用语言更改。", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    .onAppear {
                        appSettings.languageCode = ""
                    }
                }
                
                // MARK: - Debug
                Section(header: Label("调试", systemImage: "chevron.left.forwardslash.chevron.right"), footer: Text("显示实验性调试数值。")) {
                    Toggle(isOn: $DebugStuff) {
                        Text("调试信息")
                    }
                    if DebugStuff {
                        Text("语言：\(localisation)")
                        Button("重置语言") {
                            UserDefaults.standard.set(["Base"], forKey: "AppleLanguages")
                            UIApplication.shared.confirmAlert(title: "需要重启", body: "应用需要重启。", onOK: {
                                exitGracefully()
                            }, noCancel: true)
                        }
                        Text("UUID: \(appSettings.usrUUID)")
                        Text("RootHelper: \(RootHelper.whatsthePath())")
                    }
                }
                
                // MARK: - Cleaner Settings
                Section(header: Label("清理", systemImage: "trash"), footer: Text("配置清理选项。")) {
                    Toggle(isOn: $appSettings.keepCheckBoxesC) {
                        Text("清理后保留选择")
                    }
                    Toggle(isOn: $appSettings.getSizes) {
                        Text("计算可清理空间")
                    }
                    .onChange(of: appSettings.getSizes) { newValue in
                        UIApplication.shared.confirmAlert(title: "需要重启", body: "应用需要重启。", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    Toggle(isOn: Binding<Bool>(
                        get: { !appSettings.tmpClean },
                        set: { appSettings.tmpClean = !$0 }
                    )) {
                        Text("安全清理（iOS 15 请开启）")
                    }
                    .onChange(of: appSettings.tmpClean) { newValue in
                        UIApplication.shared.confirmAlert(title: "需要重启", body: "应用需要重启。", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    
                    if DebugStuff {
                        HStack {
                            Text("最小文件：")
                            Spacer()
                            TextField("50.0 MB", text: $MinimCal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: MinimCal) { newValue in
                                    MinimCal = newValue.replacingOccurrences(of: ",", with: ".")
                                }
                        }
                        .onAppear {
                            MinimCal = "\(appSettings.minimSizeC)"
                        }
                        .onChange(of: MinimCal) { newValue in
                            appSettings.minimSizeC = Double(MinimCal) ?? 50.0
                        }
                    }
                }
                
                // MARK: - LocSim Settings
                Section(header: Label("虚拟定位", systemImage: "location.fill.viewfinder"), footer: Text("配置定位模拟设置。")) {
                    Toggle(isOn: $appSettings.locSimMultipleAttempts) {
                        Text("尝试多次停止定位模拟")
                    }
                    if appSettings.locSimMultipleAttempts {
                        HStack {
                            Text("尝试次数：")
                            Spacer()
                            TextField("3", text: $LocSimTries)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        .onAppear {
                            LocSimTries = "\(appSettings.locSimAttemptNB)"
                        }
                        .onChange(of: LocSimTries) { newValue in
                            appSettings.locSimAttemptNB = Int(LocSimTries) ?? 1
                        }
                    }
                }
                
                // MARK: - Startup
                Section(header: Label("启动", systemImage: "play"), footer: Text("自定义启动行为。")) {
                    Picker("默认标签页", selection: $defaultTab) {
                        ForEach(Array(defaultTabList.keys).sorted(), id: \.self) { key in
                            Text(defaultTabList[key] ?? "")
                                .tag(key)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: defaultTab) { newValue in
                        appSettings.defaultTab = defaultTab
                        UIApplication.shared.confirmAlert(title: "需要重启", body: "应用需要重启。", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    Toggle(isOn: $appSettings.tsBypass) {
                        Text("跳过 TrollStore 弹窗")
                    }
                    .onChange(of: appSettings.tsBypass) { newValue in
                        AlertKitAPI.present(title: "已保存！", icon: .done, style: .iOS17AppleMusic, haptic: .success)
                    }
                }
                
                // MARK: - About
                Section(header: Label("关于", systemImage: "info.circle")) {
                    HStack {
                        Text("应用")
                        Spacer()
                        Text("Andromeda v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("son3ra1n")
                            .foregroundColor(.indigo)
                    }
                    Button(action: {
                        if let url = URL(string: "https://github.com/son3ra1n/Andromeda") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("源代码")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.indigo)
                        }
                    }
                }
                
                // MARK: - Acknowledgments
                Section(header: Label("致谢", systemImage: "heart.fill"), footer: Text("Andromeda is inspired by and built upon the Geranium project by c22dev. Licensed under GPL-3.0.")) {
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://github.com/c22dev/Geranium")!)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Geranium by c22dev")
                                    .foregroundColor(.primary)
                                Text("原项目及核心架构")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://github.com/BomberFish/Geranium")!)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("BomberFish")
                                    .foregroundColor(.primary)
                                Text("守护进程列表贡献")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}
