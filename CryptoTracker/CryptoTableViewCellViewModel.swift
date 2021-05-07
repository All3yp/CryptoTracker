//
//  CryptoTableViewCellViewModel.swift
//  CryptoTracker
//
//  Created by Alley Pereira on 07/05/21.
//

import Foundation

class CryptoTableViewCellViewModel {
    let name: String
    let symbol: String
    let price: String
    let iconURL: URL?
    var iconData: Data?

    init(
        name: String,
        symbol: String,
        price: String,
        iconURL: URL?
    ) {
        self.name = name
        self.symbol = symbol
        self.price = price
        self.iconURL = iconURL
    }
}
