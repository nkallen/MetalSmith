//
//  FolderWatcher.swift
//  Sourcery
//
//  Created by Krzysztof Zabłocki on 24/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

#if os(OSX)
public enum FolderWatcher {

    public struct Event {
        public let path: String
        public let flag: Flag

        public struct Flag: OptionSet {
            public let rawValue: FSEventStreamEventFlags
            public init(rawValue: FSEventStreamEventFlags) {
                self.rawValue = rawValue
            }
            init(_ value: Int) {
                self.rawValue = FSEventStreamEventFlags(value)
            }

            public static let isDirectory = Flag(kFSEventStreamEventFlagItemIsDir)
            public static let isFile = Flag(kFSEventStreamEventFlagItemIsFile)

            public static let created = Flag(kFSEventStreamEventFlagItemCreated)
            public static let modified = Flag(kFSEventStreamEventFlagItemModified)
            public static let removed = Flag(kFSEventStreamEventFlagItemRemoved)
            public static let renamed = Flag(kFSEventStreamEventFlagItemRenamed)

            public static let isHardlink = Flag(kFSEventStreamEventFlagItemIsHardlink)
            public static let isLastHardlink = Flag(kFSEventStreamEventFlagItemIsLastHardlink)
            public static let isSymlink = Flag(kFSEventStreamEventFlagItemIsSymlink)
            public static let changeOwner = Flag(kFSEventStreamEventFlagItemChangeOwner)
            public static let finderInfoModified = Flag(kFSEventStreamEventFlagItemFinderInfoMod)
            public static let inodeMetaModified = Flag(kFSEventStreamEventFlagItemInodeMetaMod)
            public static let xattrsModified = Flag(kFSEventStreamEventFlagItemXattrMod)

            public var description: String {
                var names: [String] = []
                if self.contains(.isDirectory) { names.append("isDir") }
                if self.contains(.isFile) { names.append("isFile") }

                if self.contains(.created) { names.append("created") }
                if self.contains(.modified) { names.append("modified") }
                if self.contains(.removed) { names.append("removed") }
                if self.contains(.renamed) { names.append("renamed") }

                if self.contains(.isHardlink) { names.append("isHardlink") }
                if self.contains(.isLastHardlink) { names.append("isLastHardlink") }
                if self.contains(.isSymlink) { names.append("isSymlink") }
                if self.contains(.changeOwner) { names.append("changeOwner") }
                if self.contains(.finderInfoModified) { names.append("finderInfoModified") }
                if self.contains(.inodeMetaModified) { names.append("inodeMetaModified") }
                if self.contains(.xattrsModified) { names.append("xattrsModified") }

                return names.joined(separator: ", ")
            }
        }
    }

    public class Local {
        private let path: String
        private var stream: FSEventStreamRef!
        private let closure: (_ events: [Event]) -> Void

        /// Creates folder watcher.
        ///
        /// - Parameters:
        ///   - path: Path to observe
        ///   - latency: Latency to use
        ///   - closure: Callback closure
        public init(path: String, latency: TimeInterval = 1/60, closure: @escaping (_ events: [Event]) -> Void) {
            self.path = path
            self.closure = closure

            func handler(_ stream: ConstFSEventStreamRef, clientCallbackInfo: UnsafeMutableRawPointer?, numEvents: Int, eventPaths: UnsafeMutableRawPointer, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIDs: UnsafePointer<FSEventStreamEventId>) {
                let eventStream = unsafeBitCast(clientCallbackInfo, to: Local.self)
                let paths = unsafeBitCast(eventPaths, to: NSArray.self)

                let events = (0..<numEvents).compactMap { idx in
                    return (paths[idx] as? String).flatMap { Event(path: $0, flag: Event.Flag(rawValue: eventFlags[idx])) }
                }

                eventStream.closure(events)
            }

            var context = FSEventStreamContext()
            context.info = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
            let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)

            stream = FSEventStreamCreate(nil, handler, &context, [path] as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), latency, flags)

            FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            FSEventStreamStart(stream)
        }

        deinit {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
    }
}
#endif
