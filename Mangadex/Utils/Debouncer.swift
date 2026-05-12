//
//  Debouncer.swift
//  Mangadex
//
//  Created by John Rion on 2025/12/15.
//

final class Debouncer {
    private var task: Task<Void, Never>?
    
    func call(
        delay: Duration = .milliseconds(300),
        action: @escaping @Sendable () async -> Void
    ) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            await action()
        }
    }
}
