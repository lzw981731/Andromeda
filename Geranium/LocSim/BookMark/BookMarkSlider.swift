//
//  BookMarkSlider.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI
import AlertKit
import CoreLocation

struct Bookmark: Identifiable {
    var id = UUID()
    var name: String
    var lat: Double
    var long: Double
}

struct BookMarkSlider: View {
    @Environment(\.dismiss) var dismiss
    @Binding var lat: Double
    @Binding var long: Double
    @State private var name = ""
    @State private var result: Bool = false
    @AppStorage("isMika") var isMika: Bool = false
    @State private var bookmarks: [Bookmark] = BookMarkRetrieve().compactMap { dict in
        guard let name = dict["name"] as? String,
              let lat = dict["lat"] as? Double,
              let long = dict["long"] as? Double else { return nil }
        return Bookmark(name: name, lat: lat, long: long)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarks) { bookmark in
                    Button(action: {
                        close()
                        LocSimManager.startLocSim(location: CLLocation(coordinate: CLLocationCoordinate2D(latitude: bookmark.lat, longitude: bookmark.long), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date()))
                        AlertKitAPI.present(
                            title: "已开始！",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }) {
                        VStack(alignment: .leading) {
                            Text("\(bookmark.name)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("纬度：\(bookmark.lat) 经度：\(bookmark.long)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onDelete(perform: deleteBookmark)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("书签")
                        .font(.title2)
                        .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if lat != 0.00 && long != 0.00 {
                            UIApplication.shared.TextFieldAlert(
                                title: "输入书签名",
                                textFieldPlaceHolder: "示例…"
                            ) { enteredText, _ in
                                let bookmarkName = enteredText ?? "未知"
                                result = BookMarkSave(lat: lat, long: long, name: bookmarkName)
                                bookmarks = BookMarkRetrieve().compactMap { dict in
                                    guard let name = dict["name"] as? String,
                                          let lat = dict["lat"] as? Double,
                                          let long = dict["long"] as? Double else { return nil }
                                    return Bookmark(name: name, lat: lat, long: long)
                                }
                            }

                        } else {
                            UIApplication.shared.confirmAlert(title: "位置被设为了 0", body: "确定要继续吗？这可能是个误操作，试试在地图上选个位置", onOK: {
                                UIApplication.shared.TextFieldAlert(title: "输入书签名", textFieldPlaceHolder: "示例…", completion: { enteredText, _ in
                                    result = BookMarkSave(lat: lat, long: long, name: enteredText ?? "未知")
                                    bookmarks = BookMarkRetrieve().compactMap { dict in
                                        guard let name = dict["name"] as? String,
                                              let lat = dict["lat"] as? Double,
                                              let long = dict["long"] as? Double else { return nil }
                                        return Bookmark(name: name, lat: lat, long: long)
                                    }
                                    AlertKitAPI.present(
                                        title: "已添加！",
                                        icon: .done,
                                        style: .iOS17AppleMusic,
                                        haptic: .success
                                    )
                                })
                            }, noCancel: false)
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .overlay(
                    Group {
                        if bookmarks.isEmpty {
                            VStack {
                                Text("暂无已保存的书签。")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .padding()
                                    .multilineTextAlignment(.center)
                                Text("To add a bookmark, select a custom location then tap the + button.")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    , alignment: .center
                )
            .onAppear {
                if isThereAnyMika(), !isMika {
                    UIApplication.shared.confirmAlert(title:"检测到 Mika 的 LocSim 书签/记录。", body: "要导入它们吗？", onOK: {
                        importMika()
                        bookmarks = BookMarkRetrieve().compactMap { dict in
                            guard let name = dict["name"] as? String,
                                  let lat = dict["lat"] as? Double,
                                  let long = dict["long"] as? Double else { return nil }
                            return Bookmark(name: name, lat: lat, long: long)
                        }
                        isMika.toggle()
                    }, noCancel: false, yes: true)
                }
            }
        }
    }

    private func deleteBookmark(at offsets: IndexSet) {
        bookmarks.remove(atOffsets: offsets)
        updateBookmarks()
        AlertKitAPI.present(
            title: "已删除！",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    let sharedUserDefaultsSuiteName = "group.live.cclerc.geraniumBookmarks"
    private func updateBookmarks() {
        let sharedUserDefaults = UserDefaults(suiteName: sharedUserDefaultsSuiteName)
        sharedUserDefaults?.set(bookmarks.map { ["name": $0.name, "lat": $0.lat, "long": $0.long] }, forKey: "bookmarks")
        sharedUserDefaults?.synchronize()
    }
    
    func close() {
        dismiss()
    }
}
