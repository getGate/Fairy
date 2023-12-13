import Foundation
import MetricKit

class Reporter {
    static let rawPath = "raw"
    static let processedPath = "processed"

    let store: ReporterStore

    init(store: ReporterStore) {
        self.store = store
    }

    func saveHang(payload: MXDiagnosticPayload) {
        guard let hangs = payload.hangDiagnostics, let hangDiagnostic = hangs.first else {
            return
        }

        let hang = HangPayload(diagnostic: hangDiagnostic)

        guard let logData = hang.jsonRepresentation() else {
            return
        }
        store.saveRawLog(logData, prefix: "hang")
    }

    func convertMetadataToDictionary(_ metadata: MXMetaData) -> [String: Any]? {
        let jsonData = metadata.jsonRepresentation()
        return try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
    }
}
