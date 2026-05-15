import Foundation

actor RateLimiter {
    private let maxTokens: Int
    private let refillInterval: TimeInterval
    private var tokens: Int
    private var lastRefill: Date

    init(maxRequests: Int, perSeconds: Double) {
        self.maxTokens = maxRequests
        self.refillInterval = perSeconds
        self.tokens = maxRequests
        self.lastRefill = Date()
    }

    func waitForToken() async throws {
        refillIfNeeded()
        if tokens > 0 {
            tokens -= 1
            return
        }
        // Wait until next refill window
        let waitTime = refillInterval - Date().timeIntervalSince(lastRefill)
        if waitTime > 0 {
            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
        refillIfNeeded()
        tokens = max(0, tokens - 1)
    }

    private func refillIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastRefill) >= refillInterval {
            tokens = maxTokens
            lastRefill = now
        }
    }
}
