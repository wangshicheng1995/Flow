//
//  FlowService.swift
//  Flow
//
//  Created on 2025-11-30.
//

import Foundation

final class FlowService {
    static let shared = FlowService()

    private let baseURL = "http://139.196.221.226:8080"

    private init() {}

    func fetchStressScore() async throws -> StressScore {
        guard let url = URL(string: "\(baseURL)/api/health/stress-score") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  200 ..< 300 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            return try decoder.decode(StressScore.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
