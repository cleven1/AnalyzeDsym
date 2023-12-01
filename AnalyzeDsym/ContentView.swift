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
                                        dsymFile = try result.get().path().replacingOccurrences(of: "dSYM/", with: "dSYM")
                                        
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
                                        ipsFile = try result.get().path().replacingOccurrences(of: " ", with: "_")
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
                }.frame(minHeight: 150, maxHeight: 300)
                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 300, maxWidth: .infinity)
    }
    
    private func analyzeHandler() {
        result = "解析中..."
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
