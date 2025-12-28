//
//  StressScoreViewModel.swift
//  Flow
//
//  Created on 2025-11-30.
//

import Foundation

@MainActor
final class StressScoreViewModel: ObservableObject {
    @Published var currentScore: Int = 40
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let healthService: HealthService

    init(healthService: HealthService = .shared) {
        self.healthService = healthService
    }

    func refreshScore() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await healthService.fetchStressScore()
            currentScore = response.score
            errorMessage = nil
        } catch let apiError as APIError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAfterUpload() {
        Task {
            await refreshScore()
        }
    }
}
