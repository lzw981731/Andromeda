//
//  CustomPaths.swift
//  Andromeda
//
//  Developed by son3ra1n.
//

import SwiftUI

struct CustomPaths: View {
    @State private var paths: [String] = UserDefaults.standard.stringArray(forKey: "savedPaths") ?? []
    @State private var newPathName = ""
    @State private var isAddingPath = false

    var body: some View {
        NavigationView {
            List {
                ForEach(paths, id: \.self) { path in
                    withAnimation {
                        Text(path)
                    }
                }
                .onDelete(perform: deletePaths)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("自定义路径")
                        .font(.title2)
                        .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIApplication.shared.confirmAlert(title: "确定要删除所有自定义路径吗？", body: "这不会清理它们，只会从列表中删除。", onOK: {
                            paths = []
                            savePaths()
                        }, noCancel: false)
                    }) {
                        if !paths.isEmpty {
                            withAnimation {
                                Text("清除")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIApplication.shared.TextFieldAlert(
                            title: "输入要添加到列表的路径：",
                            textFieldPlaceHolder: "/var/mobile/DCIM/"
                        ) { chemin, _ in
                            if let chemin = chemin, !chemin.isEmpty {
                                paths.append(chemin)
                                savePaths()
                                isAddingPath.toggle()
                            } else {
                                UIApplication.shared.alert(title: "输入为空！！", body: "请输入路径。")
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .overlay(
            Group {
                if paths.isEmpty {
                    VStack {
                        Text("暂无已保存的路径。")
                            .foregroundColor(.secondary)
                            .font(.title)
                            .padding()
                            .multilineTextAlignment(.center)
                        Text("点击 + 按钮添加路径。")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            , alignment: .center
        )
    }

    func deletePaths(at offsets: IndexSet) {
        paths.remove(atOffsets: offsets)
        savePaths()
    }

    func savePaths() {
        UserDefaults.standard.set(paths, forKey: "savedPaths")
    }

    @ViewBuilder
    func addPathView() -> some View {
        VStack {
            Text("添加新路径")
                .font(.headline)
                .padding()

            TextField("输入路径名称", text: $newPathName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Spacer()
                Button("取消") {
                    isAddingPath.toggle()
                }
                .padding()

                Button("保存") {
                    if !newPathName.isEmpty {
                        paths.append(newPathName)
                        savePaths()
                        isAddingPath.toggle()
                    }
                }
                .padding()
                .disabled(newPathName.isEmpty)
            }
        }
        .padding()
    }
}

struct CustomPaths_Previews: PreviewProvider {
    static var previews: some View {
        CustomPaths()
    }
}
