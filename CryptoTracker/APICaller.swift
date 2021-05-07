//
//  APICaller.swift
//  CryptoTracker
//
//  Created by Alley Pereira on 06/05/21.
//

import Foundation

final class APICaller {

    static let shared = APICaller()

    private struct Constants {
        static let apiKey = "795BF9A5-03F7-4E68-A820-6C9857573E84"
        static let endpoint = "https://rest.coinapi.io/v1/assets/?apikey=\(apiKey)"
        static let assetEndpoint = "https://rest.coinapi.io/v1/assets/icons/32/?apikey=\(apiKey)"
    }

    private init () {}

    public var icons: [Icon] = []
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    // MARK: - Public
    public func getAllCryptoData(completion: @escaping (Result<[Crypto], Error>) -> Void) {

        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }

        guard let url = URL(string: Constants.endpoint) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success(cryptos.sorted { first, second -> Bool in
                    return first.price_usd ?? 0 > second.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func getAllIcons() {

        guard let url = URL(string: Constants.assetEndpoint) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) {  [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}
