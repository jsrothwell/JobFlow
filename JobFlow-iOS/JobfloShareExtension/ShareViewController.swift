import UIKit
import SwiftUI
import UniformTypeIdentifiers

/// Principal class of the JobfloShareExtension.
final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedContent { [weak self] urlString, pageTitle in
            DispatchQueue.main.async {
                self?.presentShareView(urlString: urlString ?? "", pageTitle: pageTitle ?? "")
            }
        }
    }

    // MARK: - Private

    private func presentShareView(urlString: String, pageTitle: String) {
        let shareView = ShareView(
            sharedURL: urlString,
            pageTitle: pageTitle,
            onSave: { [weak self] job in
                PendingJobWriter.append(job)
                self?.extensionContext?.completeRequest(returningItems: nil)
            },
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(
                    withError: NSError(
                        domain: Bundle.main.bundleIdentifier ?? "JobfloShareExtension",
                        code: NSUserCancelledError
                    )
                )
            }
        )

        let hosting = UIHostingController(rootView: shareView)
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hosting.didMove(toParent: self)
    }

    private func extractSharedContent(completion: @escaping (_ url: String?, _ title: String?) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            completion(nil, nil)
            return
        }

        let pageTitle = item.attributedContentText?.string
            ?? item.attributedTitle?.string

        guard let attachments = item.attachments, !attachments.isEmpty else {
            completion(nil, pageTitle)
            return
        }

        let urlTypeID = UTType.url.identifier
        for provider in attachments where provider.hasItemConformingToTypeIdentifier(urlTypeID) {
            provider.loadItem(forTypeIdentifier: urlTypeID, options: nil) { value, _ in
                let urlString: String?
                switch value {
                case let url as URL:    urlString = url.absoluteString
                case let str as String: urlString = str
                default:               urlString = nil
                }
                completion(urlString, pageTitle)
            }
            return  // only process the first URL attachment
        }

        completion(nil, pageTitle)
    }
}
