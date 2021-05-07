//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Alley Pereira on 06/05/21.
//

import UIKit
//APi caller
// UI to show different cryptos
// MVVM

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoTableViewCell")
        return tableView
    }()

    private var viewModels = [CryptoTableViewCellViewModel]()

    static let numberFormatter: NumberFormatter = {
        let formater = NumberFormatter()
        formater.locale = .current //Locale.init(identifier: "pt_br")
        formater.allowsFloats = true
        formater.numberStyle = .currency
        formater.formatterBehavior = .default
        return formater
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.allowsSelection = false

        title = "Crypto Tracker"

        tableView.delegate = self
        tableView.dataSource = self

        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in

                    let price = model.price_usd ?? 0
                    let formater = ViewController.numberFormatter
                    let priceString = formater.string(from: NSNumber(value: price))

                    let iconURL = URL(string:
                                        APICaller.shared.icons.filter({ icon in
                                            icon.asset_id == icon.asset_id
                                        }).first?.url ?? ""
                    )

                    return CryptoTableViewCellViewModel(
                        name: model.name ?? "N/A",
                        symbol: model.asset_id,
                        price: priceString ?? "N/A",
                        iconURL: iconURL
                    )

                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

            case .failure(let error):
                print("Error \(error)")
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.identifier,
                                                       for: indexPath)  as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

