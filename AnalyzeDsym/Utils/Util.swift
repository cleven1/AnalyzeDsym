//
//  Utils.swift
//  AnalyzeDsym
//
//  Created by zhaoyongqiang on 2023/11/27.
//

import Foundation

enum Util {
    /// 执行脚本命令
    ///
    /// - Parameters:
    ///   - command: 命令行内容
    ///   - needAuthorize: 执行脚本时,是否需要 sudo 授权
    /// - Returns: 执行结果
    static func runCommand(_ command: String, needAuthorize: Bool) async throws -> (isSuccess: Bool, executeResult: String?) {
        let scriptWithAuthorization = """
        do shell script "\(command)" with administrator privileges
        """
        
        let scriptWithoutAuthorization = """
        do shell script "\(command)"
        """
        
        let script = needAuthorize ? scriptWithAuthorization : scriptWithoutAuthorization
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary? = nil
        
        return try await withUnsafeThrowingContinuation { continuation in
            let result = appleScript!.executeAndReturnError(&error)
            if let error = error {
                print("执行 \n\(command)\n命令出错:")
                print(error)
                continuation.resume(returning: (false, nil))
            }
            continuation.resume(returning: (true, result.stringValue))
        }
    }
}

