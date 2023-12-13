import Foundation
import MetricKit

struct HangPayload {
    let meta: HangMetaData
    let stackTree: HangStackTree?

    init(diagnostic: MXHangDiagnostic) {
        meta = HangMetaData(mxMeta: diagnostic.metaData, duration: diagnostic.hangDuration.value)

        stackTree = HangStackTree.clstree(from: diagnostic.callStackTree)
    }

    func dictionaryRepresentation() -> [AnyHashable: Any] {
        guard let stackTree else {
            return [:]
        }
        var dictionary = [AnyHashable: Any]()
        dictionary["meta"] = meta.dictionaryRepresentation()
        dictionary["stackTree"] = stackTree.dictionaryRepresentation()
        return dictionary
    }

    func jsonRepresentation() -> Data? {
        let dictionary = dictionaryRepresentation()
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return data
        } catch {
            print("[Fairy] generate hang report failed \(error)")
        }
        return nil
    }
}

struct HangMetaData {
    let appBuildVersion: String
    let regionFormat: String
    var hangDuration: String
    let osVersion: String
    let deviceType: String
    let platformArchitecture: String

    init(
        appBuildVersion: String,
        regionFormat: String,
        hangDuration: String,
        osVersion: String,
        deviceType: String,
        platformArchitecture: String
    ) {
        self.appBuildVersion = appBuildVersion
        self.regionFormat = regionFormat
        self.hangDuration = hangDuration
        self.osVersion = osVersion
        self.deviceType = deviceType
        self.platformArchitecture = platformArchitecture
    }

    init(mxMeta: MXMetaData, duration: Double) {
        appBuildVersion = mxMeta.applicationBuildVersion
        regionFormat = mxMeta.regionFormat
        hangDuration = String(duration)
        osVersion = mxMeta.osVersion
        deviceType = mxMeta.deviceType
        platformArchitecture = mxMeta.platformArchitecture
    }

    func dictionaryRepresentation() -> [String: Any] {
        [
            "appBuildVersion": appBuildVersion,
            "regionFormat": regionFormat,
            "hangDuration": hangDuration,
            "osVersion": osVersion,
            "deviceType": deviceType,
            "platformArchitecture": platformArchitecture,
        ]
    }
}

struct HangStackTree {
    var callStackPerThread: Bool
    var threads: [FairyCLSThread]

    init(callStackPerThread: Bool, threads: [FairyCLSThread]) {
        self.callStackPerThread = callStackPerThread
        self.threads = threads
    }

    static func clstree(from mxCallStackTree: MXCallStackTree) -> HangStackTree? {
        let jsonCallStackTree = mxCallStackTree.jsonRepresentation()

        guard let jsonDictionary = try? JSONSerialization.jsonObject(
            with: jsonCallStackTree,
            options: []
        ) as? [String: Any] else {
            return nil
        }

        let callStackPerThread = jsonDictionary["callStackPerThread"] as? Bool ?? false

        var threads = [FairyCLSThread]()
        let callStacks = jsonDictionary["callStacks"] as? [[String: Any]] ?? []
        for object in callStacks {
            var frames = [HangFrame]()
            if let rootFrames = object["callStackRootFrames"] as? [[String: Any]] {
                flattenSubFrames(rootFrames, into: &frames)
            }

            let threadBlamed = object["threadAttributed"] as? Bool ?? false
            let thread = FairyCLSThread(threadBlamed: threadBlamed, frames: frames)
            threads.append(thread)
        }

        return HangStackTree(callStackPerThread: callStackPerThread, threads: threads)
    }

    static func flattenSubFrames(
        _ callStacks: [[String: Any]],
        into frames: inout [HangFrame]
    ) {
        guard let rootFrames = callStacks.first else { return }

        let frame = HangFrame(raw: rootFrames)
        frames.append(frame)

        if let subFrames = rootFrames["subFrames"] as? [[String: Any]] {
            flattenSubFrames(subFrames, into: &frames)
        }
    }

    func dictionaryRepresentation() -> [AnyHashable: Any] {
        [
            "callStackPerThread": callStackPerThread,
            "threads": threads.map { aThread in
                aThread.dictionaryRepresentation()
            },
        ]
    }
}

struct HangFrame {
    var address: Int64 = 0
    var sampleCount: Int64
    var offsetIntoBinaryTextSegment: Int64
    var binaryName: String
    var binaryUUID: String

    init(raw: [String: Any]) {
        offsetIntoBinaryTextSegment = raw["offsetIntoBinaryTextSegment"] as? Int64 ?? 0
        address = raw["address"] as? Int64 ?? 0
        sampleCount = raw["sampleCount"] as? Int64 ?? 0
        binaryUUID = raw["binaryUUID"] as? String ?? ""
        binaryName = raw["binaryName"] as? String ?? ""
    }

    func dictionaryRepresentation() -> [String: Any] {
        [
            "address": address,
            "offsetIntoBinaryTextSegment": offsetIntoBinaryTextSegment,
            "sampleCount": sampleCount,
            "binaryName": binaryName,
            "binaryUUID": binaryUUID,
        ]
    }
}

struct FairyCLSThread {
    var threadBlamed: Bool
    var frames: [HangFrame]

    init(threadBlamed: Bool, frames: [HangFrame]) {
        self.threadBlamed = threadBlamed
        self.frames = frames
    }

    func dictionaryRepresentation() -> [String: Any] {
        [
            "threadBlamed": threadBlamed,
            "frames": frames.map { aFrame in
                aFrame.dictionaryRepresentation()
            },
        ]
    }
}
