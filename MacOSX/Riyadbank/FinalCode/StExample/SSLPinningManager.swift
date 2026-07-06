import Foundation
import CommonCrypto

final class SSLPinningManager: NSObject {
    static let shared = SSLPinningManager()

    // Add production hosts and SHA-256 public key hashes here.
    // Example:
    // "api.example.com": ["BASE64_ENCODED_SHA256_PUBLIC_KEY_HASH"]
    private let pinnedPublicKeyHashes: [String: Set<String>] = [:]

    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private override init() {
        super.init()
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        session.dataTask(with: request, completionHandler: completionHandler)
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        session.dataTask(with: url, completionHandler: completionHandler)
    }
}

extension SSLPinningManager: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host.lowercased()
        guard let pinnedHashes = hashes(for: host), !pinnedHashes.isEmpty else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let policy = SecPolicyCreateSSL(true, host as CFString)
        SecTrustSetPolicies(serverTrust, policy)

        guard isServerTrustValid(serverTrust),
              serverTrustContainsPinnedKey(serverTrust, pinnedHashes: pinnedHashes) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}

private extension SSLPinningManager {
    func hashes(for host: String) -> Set<String>? {
        if let exactMatch = pinnedPublicKeyHashes[host] {
            return exactMatch
        }

        let wildcardMatch = pinnedPublicKeyHashes.first { pinnedHost, _ in
            guard pinnedHost.hasPrefix("*.") else { return false }
            let domain = String(pinnedHost.dropFirst(2))
            return host == domain || host.hasSuffix(".\(domain)")
        }

        return wildcardMatch?.value
    }

    func isServerTrustValid(_ serverTrust: SecTrust) -> Bool {
        if #available(iOS 13.0, *) {
            return SecTrustEvaluateWithError(serverTrust, nil)
        }

        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &result)
        return status == errSecSuccess && (result == .unspecified || result == .proceed)
    }

    func serverTrustContainsPinnedKey(_ serverTrust: SecTrust, pinnedHashes: Set<String>) -> Bool {
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0 else { return false }

        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index),
                  let publicKey = SecCertificateCopyKey(certificate),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
                continue
            }

            if pinnedHashes.contains(sha256Base64(publicKeyData)) {
                return true
            }
        }

        return false
    }

    func sha256Base64(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return Data(digest).base64EncodedString()
    }
}
