//
//  ChartView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2019-04-02.
//  Copyright © 2019 breadwallet LLC. All rights reserved.
//

import UIKit
import QuartzCore

class ChartView: UIView {
    
    var historyPeriod = HistoryPeriod.defaultPeriod {
        didSet {
            hideScrubber()
            fetchHistory(forPeriod: historyPeriod)
        }
    }
    
    var shouldHideChart: (() -> Void)?
    private var currency: Currency
    private var values = [HistoryPeriod: [Int]]()
    private var hasPerformedInitialLayout = false
    private let historyFetcher = HistoryFetcher()
    var scrubberDidBegin: (() -> Void)?
    var scrubberDidEnd: (() -> Void)?
    var scrubberDidUpdateToValues: ((String, String) -> Void)? //(Price, Date) eg. $120.0, Jan 5th
    
    private func setCoordinates() {
        endCircle.isHidden = true
        let width = bounds.width - Margins.large.rawValue
        let height = bounds.height
        guard let currentValues = values[historyPeriod] else { return }
        guard height > 0, !currentValues.isEmpty else { return }
        hasPerformedInitialLayout = true
        
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = width / CGFloat(currentValues.count - 1)
            return CGFloat(column) * spacing
        }
        
        let maxValue = currentValues.max() ?? 0
        
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * height
            return !y.isNaN ? height - y : 0 // maxValue could be 0, so we need to guard against NaN
        }
        
        coordinates = [CGPoint]()
        for i in 0..<currentValues.count {
            coordinates.append(CGPoint(x: columnXPoint(i), y: columnYPoint(currentValues[i])))
        }
        
        DispatchQueue.main.async {
            self.bezierView.drawBezierCurve(bezierViewDataPoints: self.coordinates,
                                            currencyColors: self.currency.colors)
        }
    }
    
    private let haptics = UIImpactFeedbackGenerator(style: .light)
    private var rawValues = [HistoryPeriod: [PriceDataPoint]]()
    private var coordinates = [CGPoint]()
    private let line = GradientView()
    private var circleY: NSLayoutConstraint?
    private var circleX: NSLayoutConstraint?
    private var lineX: NSLayoutConstraint?
    private var circleSize: CGFloat = 6.0
    private var endCircleSize: CGFloat = 4.0
    private let bezierView = BezierView()
    private let touchView = UIView()
    private let circle = UIView()
    private let endCircle = UIView()
    
    private var endCircleX: NSLayoutConstraint?
    private var endCircleY: NSLayoutConstraint?
    
    private var scrubberPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            guard oldValue != scrubberPoint else { return }
            circleX?.constant = scrubberPoint.x
            circleY?.constant = scrubberPoint.y
            lineX?.constant = scrubberPoint.x
            haptics.impactOccurred()
        }
    }
    
    private var index: Int = 0 {
        didSet {
            guard let periodValues = rawValues[historyPeriod] else { return }
            guard periodValues.count > index else { return }
            let placeHolderRate = Rate(code: Store.state.defaultCurrencyCode, name: "", rate: periodValues[index].close, reciprocalCode: "")
            scrubberDidUpdateToValues?(placeHolderRate.localString(forCurrency: currency), historyPeriod.dateFormatter.string(from: periodValues[index].time))
        }
    }
    
    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        addSubviews()
        addConstraints()
        setInitialData()
    }
    
    private func addSubviews() {
        addSubview(circle)
        addSubview(line)
        addSubview(bezierView)
        addSubview(touchView)
        addSubview(endCircle)
    }
    
    private func addConstraints() {
        circleX = circle.centerXAnchor.constraint(equalTo: leadingAnchor)
        circleY = circle.centerYAnchor.constraint(equalTo: topAnchor)
        
        circle.constrain([
            circleY,
            circleX,
            circle.widthAnchor.constraint(equalToConstant: circleSize),
            circle.heightAnchor.constraint(equalToConstant: circleSize)])
        
        lineX = line.centerXAnchor.constraint(equalTo: leadingAnchor)
        line.constrain([
            lineX,
            line.widthAnchor.constraint(equalToConstant: 1.0),
            line.topAnchor.constraint(equalTo: topAnchor, constant: -10),
            line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10)])
        
        touchView.constrain([
            touchView.leadingAnchor.constraint(equalTo: leadingAnchor),
            touchView.bottomAnchor.constraint(equalTo: bottomAnchor),
            touchView.trailingAnchor.constraint(equalTo: trailingAnchor),
            touchView.topAnchor.constraint(equalTo: topAnchor, constant: -40.0)])
        
        bezierView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(-Margins.large.rawValue)
        }
        
        endCircle.pin(toSize: CGSize(width: endCircleSize, height: endCircleSize))
        endCircleX = endCircle.centerXAnchor.constraint(equalTo: leadingAnchor)
        endCircleY = endCircle.centerYAnchor.constraint(equalTo: topAnchor)
        endCircle.constrain([endCircleX, endCircleY])
    }
    
    private func setInitialData() {
        backgroundColor = .clear
        
        let panGr = InitialPointPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        touchView.addGestureRecognizer(panGr)
        
        panGr.didTapAtInitialPoint = { point in
            self.showScrubber()
            self.setIndex(forPoint: point)
        }
        
        panGr.touchesDidEnd = {
            self.hideScrubber()
        }
        
        circle.backgroundColor = currency.colors.0
        circle.layer.cornerRadius = circleSize / 2.0
        circle.clipsToBounds = true
        
        endCircle.backgroundColor = currency.colors.1
        endCircle.layer.cornerRadius = endCircleSize / 2.0
        endCircle.clipsToBounds = true
        endCircle.isHidden = true
        
        line.backgroundColor = circle.backgroundColor
        
        hideScrubber()
        
        haptics.prepare()
        bezierView.backgroundColor = .clear
        
        addAnimationCompletion()
        
        //Fetch initial history period
        fetchHistory(forPeriod: historyPeriod)
    }
    
    private func addAnimationCompletion() {
        bezierView.didFinishAnimation = { [weak self] in
            guard let self = self else { return }
            self.endCircleX?.constant = self.coordinates.last?.x ?? 0
            self.endCircleY?.constant = self.coordinates.last?.y ?? 0
            self.endCircle.isHidden = false
            let duration = 0.3
            let scale: CGFloat = 3.0
            let grow = CATransform3DMakeScale(scale, scale, 1.0)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                self.endCircle.layer.transform = grow
            }, completion: { _ in
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    self.endCircle.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        }
    }
    
    private func hideScrubber() {
        line.isHidden = true
        circle.isHidden = true
        scrubberDidEnd?()
    }
    
    private func showScrubber() {
        line.isHidden = false
        circle.isHidden = false
        scrubberDidBegin?()
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        setIndex(forPoint: sender.location(in: self))
    }
    
    private func setIndex(forPoint: CGPoint) {
        //Find closest coordinate
        var nearestPoint: CGPoint?
        var i = 0
        var foundIndex = 0
        coordinates.forEach {
            if nearestPoint == nil {
                nearestPoint = $0
            }
            let newDifference = abs($0.x - forPoint.x)
            let oldDifference = abs(nearestPoint!.x - forPoint.x)
            
            if newDifference < oldDifference {
                nearestPoint = $0
                foundIndex = i
            }
            i += 1
        }
        
        if nearestPoint != nil {
            scrubberPoint = nearestPoint!
            index = foundIndex
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !hasPerformedInitialLayout else { return }
        endCircle.isHidden = true
        setCoordinates()
    }
    
    private func fetchHistory(forPeriod period: HistoryPeriod) {
        guard let id = currency.coinGeckoId else { return }
        historyFetcher.fetchHistory(forCode: id, period: period, callback: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.rawValues[period] = data
                var vals = data.map { $0.close }
                var min = vals.min() ?? 0
                
                //scale for currencies that to small
                while min < 1 {
                    vals = vals.map { $0 * 1000.0 }
                    min = vals.min() ?? 0
                }
                
                self.values[period] = vals.map { 1.2 * $0 - min }.map { Int($0) } //add 20% baseline and cast to Ints
                if period == self.historyPeriod {
                    self.endCircle.isHidden = true
                    self.setCoordinates()
                }
            case .unavailable:
                self.shouldHideChart?()
            }
        })
    }
    
    // overriding hit test is to enable dragging outside of the graph view's bounds
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class InitialPointPanGestureRecognizer: UIPanGestureRecognizer {
    var didTapAtInitialPoint: ((CGPoint) -> Void)?
    var touchesDidEnd: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        didTapAtInitialPoint?(touches.first!.location(in: view))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        touchesDidEnd?()
    }
}
