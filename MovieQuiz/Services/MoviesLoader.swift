//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ekaterina on 13.04.2026.
//

import Foundation

enum NetworkError: Error {
    case apiError(String)
}

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    private let jsonDecoder = JSONDecoder()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytff") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: self.mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try jsonDecoder.decode(MostPopularMovies.self, from: data)

                    if mostPopularMovies.errorMessage.isEmpty {
                        handler(.success(mostPopularMovies))
                    } else {
                        handler(.failure(NetworkError.apiError(mostPopularMovies.errorMessage)))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
