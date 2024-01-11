//
//  ContentView.swift
//  AnalyzeDsym
//
//  Created by zhaoyongqiang on 2023/11/27.
//

import SwiftUI

struct ContentView: View {
    @State private var dsymFile: String = ""
    @State private var ipsFile: String = ""
    @State private var isShowingDsymFilePicker = false
    @State private var isShowingIpsFilePicker = false
    @State private var result: String = "待解析...."
    
    var body: some View {
        VStack {
            HStack(content: {
                Text("dsym文件地址:")
                TextField("Enter dsym file path", text: $dsymFile)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                                isShowingDsymFilePicker = true
                            }) {
                                Text("选择文件")
                            }
                            .fileImporter(
                                isPresented: $isShowingDsymFilePicker,
                                allowedContentTypes: [.item],
                                onCompletion: { result in
                                    do {
                                        dsymFile = try result.get().path().replacingOccurrences(of: "dSYM/", with: "dSYM").trimmingCharacters(in: .whitespacesAndNewlines)
                                        
                                        // 处理文件
                                    } catch {
                                        // 处理错误
                                    }
                                }
                            )
            })
            HStack(content: {
                Text("crash文件地址:")
                TextField("Enter ips file path", text: $ipsFile)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(action: {
                                isShowingIpsFilePicker = true
                            }) {
                                Text("选择文件")
                            }
                            .fileImporter(
                                isPresented: $isShowingIpsFilePicker,
                                allowedContentTypes: [.text],
                                onCompletion: { result in
                                    do {
                                        ipsFile = try result.get().path().trimmingCharacters(in: .whitespacesAndNewlines)
                                        // 处理文件
                                    } catch {
                                        // 处理错误
                                    }
                                }
                            )
            })
            Button(action: { self.analyzeHandler() }, label: {
                Text("解析")
                    .frame(width: 80, height: 40)
            }).disabled(self.dsymFile.isEmpty || self.ipsFile.isEmpty)
            Spacer()
            HStack {
                ScrollView(.vertical) {
                    Text(result).font(.system(size: 16))
                }.frame(minHeight: 150, maxHeight: .infinity)
                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 300, maxWidth: .infinity)
    }
    
    private func analyzeHandler() {
        result = "解析中..."
        if dsymFile.contains(where: { $0.isWhitespace }) {
            result = "dSYM文件路径中存在空格,请修改"
            return
        }
        if ipsFile.contains("%") {
            result = "crash文件路径中存在空格,请修改"
            return
        }
        if !FileManager.default.fileExists(atPath: dsymFile) {
            result = "dSYM文件不存在, 请检查路径"
            return
        }
        if !FileManager.default.fileExists(atPath: ipsFile) {
            result = "crash文件不存在, 请检查路径"
            return
        }
        guard let scriptPath = Bundle.main.path(forResource: "Analyze", ofType: "sh") else { return }
        Task {
            let script = scriptPath + " \(dsymFile) \(ipsFile)"
           guard let result = try? await Util.runCommand(script,
                                                         needAuthorize: false) else { return }
            if result.isSuccess {
                self.result = result.executeResult ?? ""
            } else {
                self.result = "解析失败"
            }
        }
    }
}

#Preview {
    ContentView()
}
