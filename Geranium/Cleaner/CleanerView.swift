//
// CleanerView.swift
// Andromeda
// Created by Constantin Clerc on 10/12/2023.

import SwiftUI

struct CleanerView: View {
    @StateObject private var appSettings = AppSettings()
    @State private var customPaths: [String] = UserDefaults.standard.stringArray(forKey: "savedPaths") ?? []
    // View Settings
    @State var defaultView: Bool = true
    @State var progressView: Bool = false
    @State var resultView: Bool = false
    @State var wannaReboot: Bool = false
    @State var customPathSheet: Bool = false
    @State var needHelpWithMyNotifs: Bool = false
    @State var storageAnalyzerSheet: Bool = false
    @State var shouldIGetSizes = AppSettings().getSizes
    
    // User Selection
    @State var safari = false
    @State var appCaches = false
    @State var otaCaches = false
    @State var leftoverCaches = false
    @State var custompathselect = false
    
    // Sizes
    @State private var isLowSize: Bool = false
    @State private var safariCacheSize: Double = 0
    @State private var GlobalCacheSize: Double = 0
    @State private var OTACacheSize: Double = 0
    @State private var leftOverCacheSize: Double = 0
    @State private var customPathsSize: Double = 0
    
    // Results
    @State private var progressAmount:CGFloat = 0
    @State var RHResult = ""
    @State var errorDetected: Bool = false
    @State var successDetected: Bool = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    cleanerViewMain()
                }
            }
            else {
                cleanerViewMain()
            }
        } else {
            NavigationView {
                cleanerViewMain()
            }
        }
    }
    
    @ViewBuilder
    private func cleanerViewMain() -> some View {
        VStack {
            // Default View if nothing is being done
            if defaultView {
                // check if smth is selected
                if safari || appCaches || otaCaches || leftoverCaches || custompathselect {
                    Button("清理！", action: {
                        UIApplication.shared.confirmAlert(title: "已选项", body: "Safari 缓存：\(truelyEnabled(safari))\n通用缓存：\(truelyEnabled(appCaches))\nOTA 更新缓存：\(truelyEnabled(otaCaches))\n应用残留缓存：\(truelyEnabled(leftoverCaches))\(customTest(isEnabled: custompathselect))\n确定要永久删除这些文件吗？\(draftWarning(isEnabled: leftoverCaches))", onOK: {
                            print("")
                            withAnimation {
                                var sizetotal = (safariCacheSize + GlobalCacheSize + OTACacheSize + leftOverCacheSize) / (1024 * 1024)
                                if sizetotal < appSettings.minimSizeC, shouldIGetSizes {
                                    isLowSize = true
                                }
                                
                                defaultView.toggle()
                                progressView.toggle()
                                wannaReboot = false
                            }
                        }, noCancel: false, yes: true)
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                }
                else {
                    Button("清理！", action: {
                        UIApplication.shared.confirmAlert(title: "未选择", body: "请至少选择一项进行清理。", onOK: {
                            print("nothing selected")
                        }, noCancel: false, yes: true)
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                    .disabled(true)
                }
                // Normal Toggles
                Toggle(isOn: $safari) {
                    Image(systemName: "safari")
                    Text("Safari 缓存")
                    if shouldIGetSizes {
                        Text("> "+String(format: "%.2f MB", safariCacheSize / (1024 * 1024)))
                    }
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                
                .onAppear {
                    if ProcessInfo().operatingSystemVersion.majorVersion == 15, appSettings.firstCleanerTime {
                        appSettings.firstCleanerTime = false
                        UIApplication.shared.confirmAlert(title: "⚠️ You are on iOS 15 ⚠️", body: "在 iOS 15 上清理可能会破坏通知和部分应用权限。要开启手机安全保护措施吗？开启后可能无法彻底清理干净，但在 iOS 15 上点“是”能保证设备安全。", onOK: {
                            appSettings.tmpClean = false
                        }, noCancel: false, onCancel: {
                            appSettings.tmpClean = true
                        }, yes: true)
                    }
                    if shouldIGetSizes {
                        getSizeForSafariCaches { size in
                            self.safariCacheSize = size
                        }
                    }
                }
                Toggle(isOn: $appCaches) {
                    Image(systemName: "app.dashed")
                    Text("通用缓存")
                    if shouldIGetSizes {
                        Text("> " + String(format: "%.2f MB", GlobalCacheSize / (1024 * 1024)))
                    }
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    if shouldIGetSizes {
                        getSizeForGeneralCaches { size in
                            self.GlobalCacheSize = size
                        }
                    }
                }
                
                Toggle(isOn: $otaCaches) {
                    Image(systemName: "restart.circle")
                    Text("OTA 更新缓存")
                    if shouldIGetSizes {
                        Text("> " + String(format: "%.2f MB", OTACacheSize / (1024 * 1024)))
                    }
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    if shouldIGetSizes {
                        getSizeForOTA { size in
                            self.OTACacheSize = size
                        }
                    }
                }
                
                Toggle(isOn: $leftoverCaches) {
                    Image(systemName: "app.badge.checkmark")
                    Text("应用残留缓存")
                    if shouldIGetSizes {
                        Text("> " + String(format: "%.2f MB", leftOverCacheSize / (1024 * 1024)))
                    }
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    if shouldIGetSizes {
                        getSizeForAppLeftover { size in
                            self.leftOverCacheSize = size
                        }
                    }
                }
                if !customPaths.isEmpty {
                    Toggle(isOn: $custompathselect) {
                        Image(systemName: "folder")
                        Text("自定义路径")
                        if shouldIGetSizes {
                            Text("> " + String(format: "%.2f MB", customPathsSize / (1024 * 1024)))
                        }
                    }
                    .toggleStyle(checkboxiOS())
                    .padding(2)
                    .onAppear {
                        if shouldIGetSizes {
                            getSizeForCustom { size in
                                self.customPathsSize = size
                            }
                        }
                    }
                }
            }
            // View being in progress
            else if progressView {
                ProgressBar(value: progressAmount)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .onAppear {
                        performCleanup()
                    }
            }
            // Success - Cleaning Report
            if successDetected, resultView {
                cleaningReportView()
            }
            // Error...
            if errorDetected, resultView {
                Image(systemName: "x.circle")
                    .foregroundColor(.red)
                    .onAppear {
                        progressAmount = 0.9
                        errorVibrate()
                    }
                Text("出错！")
                    .foregroundStyle(.red)
                Text("RootHelper 出错。")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                
                Button("重试", action: {
                    withAnimation {
                        progressAmount = 0
                        if !appSettings.keepCheckBoxesC {
                            safari = false
                            appCaches = false
                            otaCaches = false
                            leftoverCaches = false
                            custompathselect = false
                        }
                        isLowSize = false
                        errorDetected.toggle()
                        resultView.toggle()
                        defaultView.toggle()
                        wannaReboot = true
                    }
                })
                .padding(10)
                .background(.red)
                .cornerRadius(8)
                .foregroundColor(.black)
                .transition(.scale)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if defaultView {
                    Text("清理")
                        .font(.title2)
                        .bold()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    needHelpWithMyNotifs.toggle()
                }) {
                    if defaultView, ProcessInfo().operatingSystemVersion.majorVersion == 15 {
                        Image(systemName: "bell.badge")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    customPathSheet.toggle()
                }) {
                    if defaultView {
                        Image(systemName: "folder.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    storageAnalyzerSheet.toggle()
                }) {
                    if defaultView {
                        Image(systemName: "chart.pie.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(.indigo)
                    }
                }
            }
        }
        .sheet(isPresented: $customPathSheet) {
            CustomPaths()
                .onDisappear {
                    UIApplication.shared.confirmAlert(title: "需要退出应用以应用更改。", body: "你可能想马上重新打开以继续。", onOK: {
                        exitGracefully()
                    }, noCancel: true)
                }
        }
        .sheet(isPresented: $needHelpWithMyNotifs) {
            NotifHelp()
        }
        .sheet(isPresented: $storageAnalyzerSheet) {
            StorageAnalyzerView()
        }
    }
    func performCleanup() {
        cleanProcess(lowSize: isLowSize, safari: safari, appCaches: appCaches, otaCaches: otaCaches, leftOverCaches:
                        leftoverCaches, custompathselect: custompathselect) { progressHandler in
            progressAmount = progressHandler
            if (progressAmount >= 0.9) {
                withAnimation {
                    progressView.toggle()
                    successDetected.toggle()
                    resultView.toggle()
                }
            }
            if (progressAmount < -5) {
                withAnimation {
                    sendLog("清理出错")
                    progressAmount = 0
                    progressView.toggle()
                    errorDetected.toggle()
                    resultView.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    private func cleaningReportView() -> some View {
        let totalCleaned = (safariCacheSize + GlobalCacheSize + OTACacheSize + leftOverCacheSize + customPathsSize) / (1024 * 1024)
        
        ScrollView {
            VStack(spacing: 20) {
                // Animated Checkmark
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 70, height: 70)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                .onAppear { successVibrate() }
                
                Text("清理完成！")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", totalCleaned))
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                    Text("已释放 MB")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Category Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("明细")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    if safari { cleanReportRow(icon: "safari", label: "Safari 缓存", size: safariCacheSize, color: .blue) }
                    if appCaches { cleanReportRow(icon: "app.dashed", label: "通用缓存", size: GlobalCacheSize, color: .orange) }
                    if otaCaches { cleanReportRow(icon: "restart.circle", label: "OTA 更新", size: OTACacheSize, color: .purple) }
                    if leftoverCaches { cleanReportRow(icon: "app.badge.checkmark", label: "应用残留", size: leftOverCacheSize, color: .pink) }
                    if custompathselect { cleanReportRow(icon: "folder", label: "自定义路径", size: customPathsSize, color: .indigo) }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Done Button
                Button(action: {
                    withAnimation {
                        progressAmount = 0
                        if !appSettings.keepCheckBoxesC {
                            safari = false; appCaches = false; otaCaches = false
                            leftoverCaches = false; custompathselect = false
                        }
                        isLowSize = false
                        successDetected.toggle(); resultView.toggle()
                        defaultView.toggle(); wannaReboot.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("完成")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
            }
            .padding(.top, 30)
        }
    }
    
    private func cleanReportRow(icon: String, label: String, size: Double, color: Color) -> some View {
        let sizeMB = size / (1024 * 1024)
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                
                GeometryReader { geo in
                    let maxSize = max(safariCacheSize, GlobalCacheSize, OTACacheSize, leftOverCacheSize, customPathsSize, 1)
                    let barWidth = (size / maxSize) * geo.size.width
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.3))
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(width: max(barWidth, 4), height: 6)
                        }
                }
                .frame(height: 6)
            }
            
            Text(String(format: "%.1f MB", sizeMB))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
}
