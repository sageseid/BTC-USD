//
//  OrderBookTableViewCell.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//

import Foundation
import UIKit

class OrderBookTableViewCell: UITableViewCell {
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with item: OrderBook.Item) {
        amountLbl.text = ValuesFormatter.amountFormat.string(from: NSNumber(value: item.amount))
        priceLbl.text = ValuesFormatter.priceFormat.string(from: NSNumber(value: item.price))
    }
}
