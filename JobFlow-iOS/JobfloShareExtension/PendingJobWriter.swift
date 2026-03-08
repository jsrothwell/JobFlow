import Foundation

enum PendingJobWriter {
    private static let appGroupID = "group.com.jobflow.ios"
    private static let fileName = "pending_jobs.json"

    private static var fileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(fileName)
    }

    private static var sharedDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    private static var sharedEncoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }

    static func append(_ job: JobApplication) {
        guard let url = fileURL else { return }
        var existing: [JobApplication] = []
        if let data = try? Data(contentsOf: url) {
            existing = (try? sharedDecoder.decode([JobApplication].self, from: data)) ?? []
        }
        existing.append(job)
        if let data = try? sharedEncoder.encode(existing) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
