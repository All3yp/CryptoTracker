//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Alley Pereira on 06/05/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoTableViewCell")
        return tableView
    }()

    private var viewModels = [CryptoTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Crypto Tracker"

        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in

                    guard let price_usd = model.price_usd else { return nil }
                    guard model.id_icon != nil else { return nil }

                    let price: Int = Int(price_usd)

                    let priceString = price.formatUsingAbbrevation()

                    let iconURL = URL(string:
                                        APICaller.shared.icons.filter({ icon in
                                            icon.asset_id == model.asset_id
                                        }).first?.url ?? ""
                    )

                    return CryptoTableViewCellViewModel(
                        name: model.name ?? model.asset_id.capitalized,
                        symbol: model.asset_id,
                        price: "$\(priceString)",
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

