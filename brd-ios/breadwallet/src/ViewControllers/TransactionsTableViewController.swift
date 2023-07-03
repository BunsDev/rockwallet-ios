//
//  TransactionsTableViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import WalletKit

class TransactionsTableViewController: UITableViewController, Subscriber {
    // MARK: - Properties and initialization
    
    typealias DataSource = UITableViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    enum Section {
        case transactions
    }
    
    init(currency: Currency, wallet: Wallet?, didSelectTransaction: @escaping ([TxListViewModel], Int) -> Void) {
        self.wallet = wallet
        self.currency = currency
        self.didSelectTransaction = didSelectTransaction
        self.showFiatAmounts = Store.state.showFiatAmounts
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        wallet?.unsubscribe(self)
        Store.unsubscribe(self)
    }
    
    let didSelectTransaction: ([TxListViewModel], Int) -> Void
    
    var filters: [TransactionFilter] = [] {
        didSet {
            guard let transfers = wallet?.transfers else { return }
            transactions = filters.reduce(transfers.sorted(by: { $0.timestamp > $1.timestamp }), { $0.filter($1) })
            prepareData()
        }
    }
    
    var didScrollToYOffset: ((CGFloat) -> Void)?
    var didStopScrolling: (() -> Void)?
    
    var wallet: Wallet? {
        didSet {
            if wallet != nil {
                subscribeToTransactionUpdates()
            }
        }
    }
    
    // MARK: - Private
    
    private lazy var emptyMessage: UILabel = {
        let view = UILabel.wrapping(font: Fonts.Body.one, color: LightColors.Text.one)
        view.textAlignment = .center
        view.text = L10n.TransactionDetails.emptyMessage
        return view
    }()
    
    private let currency: Currency
    private var remainingExchanges = [ExchangeDetail]()
    private var exchanges: [ExchangeDetail] = []
    private var transactions: [Transaction] = []
    private var allTransactions: [TxListViewModel] {
        // Combine transactions and exchanges into 1 array.
        
        var items = [TxListViewModel]()
        
        for item in exchanges {
            items.append(.init(exchange: item, currency: currency))
        }
        
        for item in transactions where exchanges.filter({ $0.orderId == item.exchange?.orderId }).isEmpty {
            items.append(.init(tx: item, currency: currency))
        }
        
        return items.sorted(by: { lhs, rhs in
            return combineTransactions(tx: lhs) > combineTransactions(tx: rhs)
        })
    }
    
    private func combineTransactions(tx: TxListViewModel) -> Double {
        let result: Double
        
        if let tx = tx.exchange {
            result = Double(tx.timestamp) / 1000
        } else if let tx = tx.tx {
            result = tx.timestamp
        } else {
            result = 0
        }
        
        return result
    }
    
    private var showFiatAmounts: Bool {
        didSet {
            updateTransactions()
        }
    }
    
    private var rate: Rate? {
        didSet {
            updateTransactions()
        }
    }
    
    private var dataSource: DataSource?
    private let sections: [Section] = [
        .transactions
    ]
    
    private var timer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TxListCell.self)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        
        setupUI()
        prepareData()
    }
    
    private func setupUI() {
        let header = SyncingHeaderView(currency: currency)
        header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SyncingHeaderView.height)
        tableView.tableHeaderView = header
        
        tableView.addSubview(emptyMessage)
        emptyMessage.constrain([
            emptyMessage.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyMessage.topAnchor.constraint(equalTo: tableView.topAnchor, constant: E.isIPhone5 ? 50.0 : AssetDetailsHeaderView.headerViewMinHeight),
            emptyMessage.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Margins.large.rawValue)
        ])
    }
    
    private func prepareData() {
        setupDataSource()
        createSnapshot(for: allTransactions)
        
        loadRemainingExchanges { [weak self] in
            self?.setupSubscriptions()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Store.trigger(name: .didViewTransactions(transactions))
    }
    
    private func setupDataSource() {
        dataSource?.defaultRowAnimation = .fade
        dataSource = DataSource(tableView: tableView) { [weak self] _, indexPath, _ in
            return self?.transactionCell(indexPath)
        }
    }
    
    private func createSnapshot(for items: [AnyHashable], completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([.transactions])
        snapshot.appendItems(items, toSection: .transactions)
        
        dataSource?.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.emptyMessage.isHidden = self?.allTransactions.isEmpty != true
            
            completion?()
        }
    }
    
    private func loadRemainingExchanges(completion: @escaping (() -> Void)) {
        ExchangeManager.shared.reload(for: currency.code) { [weak self] exchanges in
            self?.remainingExchanges = exchanges ?? []
            
            completion()
        }
    }
    
    private func setupSubscriptions() {
        Store.subscribe(self,
                        selector: { $0.showFiatAmounts != $1.showFiatAmounts },
                        callback: { [weak self] state in
            self?.showFiatAmounts = state.showFiatAmounts
        })
        
        Store.subscribe(self,
                        selector: { [weak self] oldState, newState in
            guard let self = self else { return false }
            return oldState[self.currency]?.currentRate != newState[self.currency]?.currentRate},
                        callback: { [weak self] state in
            guard let self = self else { return }
            self.rate = state[self.currency]?.currentRate
        })
        
        Store.subscribe(self, name: .txMetaDataUpdated("")) { [weak self] trigger in
            guard let trigger = trigger, case .txMetaDataUpdated = trigger else { return }
            _ = self?.updateTransactions()
        }
        
        subscribeToTransactionUpdates()
    }
    
    private func subscribeToTransactionUpdates() {
        wallet?.requestReceiveAddressSync()
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { [weak self] _ in
                self?.wallet?.requestReceiveAddressSync()
            }) // Repeat every 15 seconds while self exists
        wallet?.subscribe(self) { [weak self] event in
            switch event {
            case .balanceUpdated,
                    .transferAdded,
                    .transferDeleted,
                    .transferChanged,
                    .transferSubmitted:
                guard let self = self else { return }
                self.updateTransactions()
            
            default:
                break
            }
        }
        
        wallet?.subscribeManager(self) { [weak self] event in
            guard case .blockUpdated = event else { return }
            self?.updateTransactions()
        }
    }
    
    private func updateTransactions() {
        guard filters.isEmpty else {
            tableView.reloadData()
            return
        }
        guard let transfers = wallet?.transfers else { return }
        
        transactions = transfers.sorted(by: { $0.timestamp > $1.timestamp })
        
        remainingExchanges.forEach { exchange in
            let source = exchange.source
            let destination = exchange.destination
            let instantDestination = exchange.instantDestination
            
            let sourceId = source.transactionId
            let destinationId = destination?.transactionId
            let instantDestinationId = instantDestination?.transactionId
            
            if let element = transactions.first(where: {
                $0.transfer.hash?.description == sourceId ||
                $0.transfer.hash?.description == destinationId ||
                $0.transfer.hash?.description == instantDestinationId
            }) {
                element.exchange = exchange
            }
        }
        
        exchanges = remainingExchanges
        
        createSnapshot(for: allTransactions)
    }
    
    // MARK: - TableView data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTransactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return transactionCell(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTransaction(allTransactions, indexPath.row)
    }
    
    private func transactionCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TxListCell = tableView.dequeueReusableCell(for: indexPath),
              let viewModel = dataSource?.itemIdentifier(for: indexPath) as? TxListViewModel else { return UITableViewCell() }
        
        cell.setTransaction(viewModel,
                            showFiatAmounts: showFiatAmounts,
                            rate: rate ?? Rate.empty)
        
        return cell
    }
}

// MARK: - ScrollView delegate

extension TransactionsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollToYOffset?(scrollView.contentOffset.y)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        didStopScrolling?()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didStopScrolling?()
    }
}
