import Foundation
import MetricKit

class MetricKitPlugin: NSObject, FairyPlugin {
    let store = ReporterStore()
    let reporter: Reporter

    override init() {
        reporter = Reporter(store: store)
    }

    func start() {
        store.prepare()

        let metricManager = MXMetricManager.shared
        metricManager.add(self)
    }
}

extension MetricKitPlugin: MXMetricManagerSubscriber {
    public func didReceive(_ payloads: [MXMetricPayload]) {
        // todo report
    }

    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        guard payloads.first != nil else { return }

        print("[Fairy] receive diagnostic payloads \(payloads.count)")
        for payload in payloads {
            if let _ = payload.hangDiagnostics {
                reporter.saveHang(payload: payload)
            }
        }
    }
}
