//
//  BtcUsdVC.swift
//  BTC-USD
//
//  Created by Noel Obaseki on 07/11/2021.
//
import UIKit
import RxSwift
import RxCocoa


class BtcUsdVC: UIViewController {
    
    // UI References IBOutlets
    @IBOutlet weak var lowLbl: UILabel!
    @IBOutlet weak var lastLbl: UILabel!
    @IBOutlet weak var highLbl: UILabel!
    @IBOutlet weak var volumeLbl: UILabel!
    @IBOutlet weak var changeLbl: UILabel!
    @IBOutlet weak var sellTableView: UITableView!
    @IBOutlet weak var buyTableView: UITableView!
    @IBOutlet weak var lostConnection: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var priceDirection: Bool? {
        didSet {
            changeLabelColour()
        }
    }
    
    private let tickerVM = BtcUsdTickerVM()
    private let orderVM = BtcUsdOrderBookVM()
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTable()
        bindTickerData()
        bindOrderBookData()
        tickerVM.onNext()
        orderVM.onNext()
    }
    
    private func changeLabelColour() {
        if priceDirection == true {
            changeLbl.textColor = UIColor.systemGreen
        } else {
            changeLbl.textColor = UIColor.systemRed
        }
    }
    
    
    private func createTable() {
        [buyTableView, sellTableView].forEach { tableView in
            tableView?.register(UINib(nibName: "OrderBookTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderBookTableViewCellReuseIdentifier")
            tableView?.separatorStyle = .none
            tableView?.allowsSelection = false
            tableView?.translatesAutoresizingMaskIntoConstraints = false
            tableView?.backgroundColor = .black
            tableView?.showsVerticalScrollIndicator = false
            tableView?.delegate = self
        }
    }
    
    
    private func bindTickerData() {
        tickerVM.hasInternetConnection
            .drive(onNext: { isConnected in
                if isConnected {
                    self.lostConnection.text = ""
                } else {
                    self.lostConnection.text = "Internet Connection Lost, Reconnecting ..."
                }
            })
            .disposed(by: disposeBag)
        
        tickerVM.direction
            .drive(onNext: { [weak self] direction in
                self?.priceDirection = direction
            })
            .disposed(by: disposeBag)
        
        tickerVM.low
            .drive(lowLbl.rx.text)
            .disposed(by: disposeBag)
        
        tickerVM.change
            .distinctUntilChanged()
            .drive(changeLbl.rx.text)
            .disposed(by: disposeBag)
        
        tickerVM.volume
            .drive(volumeLbl.rx.text)
            .disposed(by: disposeBag)
        
        tickerVM.high
            .drive(highLbl.rx.text)
            .disposed(by: disposeBag)
        
        tickerVM.lastPrice
            .distinctUntilChanged()
            .drive(lastLbl.rx.text)
            .disposed(by: disposeBag)
       }
    

    private func bindOrderBookData() {
        orderVM.isLoading
            .drive(onNext: { isLoading in
                if isLoading {
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        orderVM.buys
            .drive(buyTableView.rx.items(cellIdentifier: "OrderBookTableViewCellReuseIdentifier", cellType: OrderBookTableViewCell.self)) { tableView, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        orderVM.sells
            .drive(sellTableView.rx.items(cellIdentifier: "OrderBookTableViewCellReuseIdentifier", cellType: OrderBookTableViewCell.self)) { tableView, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        }
}


extension BtcUsdVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UINib(nibName: "OrderBookHeaderView", bundle: Bundle.main).instantiate(withOwner: tableView, options: nil).first as? UIView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard buyTableView.numberOfRows(inSection: 0) == sellTableView.numberOfRows(inSection: 0) else { return }
        switch scrollView {
        case sellTableView:
            buyTableView.contentOffset = scrollView.contentOffset
        case buyTableView:
            sellTableView.contentOffset = scrollView.contentOffset
        default:
            break
        }
    }
}
