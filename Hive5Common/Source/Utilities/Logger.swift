//
//  Logger.swift
//  Hive5Common
//
//  Created by Xule Zhou on 6/2/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

//I gave up on finding a logger that can really be used...so i'll just write my own.
//Yay!! one less framework to compile
public class HFLog{
    public enum LogLevel: String, Comparable {
        /**
         Fatal error will cause the process to crash directly ( fatalError(:D) ).
         
         - important:
         There will be no further procedure after this call. Anything not saved will be lost!
         */
        case fatal = "FATAL"
        case error = "ERROR"
        case warn = "WARN"
        case info = "INFO"
        case debug = "DEBUG"
        case verbose = "VERBOSE"
        
        fileprivate static let levels: [LogLevel] = [.verbose, .debug, .info, .warn, .error, .fatal]
        
        public static func < (lhs: HFLog.LogLevel, rhs: HFLog.LogLevel) -> Bool {
            return levels.index(of: lhs)! < levels.index(of: rhs)!
        }
        
        public static func <= (lhs: HFLog.LogLevel, rhs: HFLog.LogLevel) -> Bool {
            return levels.index(of: lhs)! <= levels.index(of: rhs)!
        }
        
        public static func > (lhs: HFLog.LogLevel, rhs: HFLog.LogLevel) -> Bool {
            return levels.index(of: lhs)! > levels.index(of: rhs)!
        }
        
        public static func >= (lhs: HFLog.LogLevel, rhs: HFLog.LogLevel) -> Bool {
            return levels.index(of: lhs)! >= levels.index(of: rhs)!
        }
    }
    
    public static var logLevel = LogLevel.info {
        //Enable the logger when new log level is set
        didSet{ enable = true }
    }
    
    public static var enable = false {
        didSet {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .medium
        }
    }
    
    fileprivate static var dateFormatter = DateFormatter()
    fileprivate static var now: String { return dateFormatter.string(from: .init()) }
    
    public class func log(_ level: LogLevel,
                          message: String,
                          file: String = #file,
                          function: String = #function,
                          line: Int = #line){
        if enable && level >= logLevel {
            var fileComponent = ""
            
            //Only log filenames when debug or verbose is enabled
            if logLevel <= .debug {
                let url = URL(fileURLWithPath: file)
                let fileExtension = url.pathExtension
                let fileName = url.deletingPathExtension().lastPathComponent
                
                fileComponent = "[\(fileName).\(fileExtension):\(line) \(function)]"
            }
            
            let formattedMessage = "\(now) \(fileComponent)[\(level.rawValue)] \(message)"
            if case .fatal = level { fatalError(formattedMessage) }
            else { print(formattedMessage) }
        }
    }
    
    public class func verbose(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line){
        log(.verbose, message: message, file: file, function: function, line: line)
    }
    
    public class func debug(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line){
        log(.debug, message: message, file: file, function: function, line: line)
    }
    
    public class func info(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line){
        log(.info, message: message, file: file, function: function, line: line)
    }
    
    public class func warn(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line){
        log(.warn, message: message, file: file, function: function, line: line)
    }
    
    public class func error(_ message: String,
                           file: String = #file,
                           function: String = #function,
                           line: Int = #line){
        log(.error, message: message, file: file, function: function, line: line)
    }
    
    public class func fatal(_ message: String,
                            file: String = #file,
                            function: String = #function,
                            line: Int = #line){
        log(.fatal, message: message, file: file, function: function, line: line)
    }
}
