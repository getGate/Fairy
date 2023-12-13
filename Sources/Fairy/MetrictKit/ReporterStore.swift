import Foundation

class ReporterStore {
    static let store = ReporterStore()

    let dateFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        return formatter
    }()

    let rawPath: URL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("fairy", isDirectory: true)
        .appendingPathComponent("raw", isDirectory: true)

    let processedPath: URL = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("fairy", isDirectory: true)
        .appendingPathComponent("processed", isDirectory: true)

    /// list files in raw dir
    func listRawFiles() -> [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: rawPath,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )

            return files
        } catch {
            print("[Fairy] list raw files failed: \(error)")
            return []
        }
    }

    /// move file from raw dir to processed dir
    func moveRawFileToProcessed(_ file: URL) -> URL? {
        let fileName = file.lastPathComponent
        let processedFile = processedPath.appendingPathComponent(fileName)

        do {
            try FileManager.default.moveItem(at: file, to: processedFile)
            return processedFile
        } catch {
            print("[Fairy] move raw file to processed failed: \(error)")
            return nil
        }
    }

    func prepare() {
        if !FileManager.default.fileExists(atPath: rawPath.path) {
            do {
                try FileManager.default.createDirectory(
                    at: rawPath,
                    withIntermediateDirectories: true
                )
            } catch {
                print("[Fairy] create fairy dir failed: \(error)")
            }
        }

        if !FileManager.default.fileExists(atPath: processedPath.path) {
            do {
                try FileManager.default.createDirectory(
                    at: processedPath,
                    withIntermediateDirectories: true
                )
            } catch {
                print("[Fairy] create fairy dir failed: \(error)")
            }
        }
    }

    @discardableResult
    func saveRawLog(_ data: Data, prefix: String) -> Bool {
        let currentDate = Date()
        let formattedDate = dateFormater.string(from: currentDate)

        let fileName = "metricskit-\(prefix)-\(formattedDate).json"

        let filePath = rawPath.appendingPathComponent(fileName)

        do {
            try data.write(to: filePath)
            return true
        } catch {
            print("[Fairy] Error writing log to file: \(error)")
            return false
        }
    }
}
