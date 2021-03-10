//
//  StockChartViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Cartography
import Charts
import UIKit

protocol IntervalDelegate: AnyObject {
    func intervalDidChange(newInterval interval: StockDetailViewModel.IntevalTime)
}

class StockChartViewController: UIViewController, ChartViewDelegate {
    // MARK: - Private Properties

    private var barHeight: CGFloat = 0
    private var activeInterval: Int = 0

    private let buttonTitles = ["D", "W", "M", "6M", "1Y", "ALL"]
    private var buttonsArray = [IntervalButton]()

    // MARK: - Public Properties

    weak var delegate: IntervalDelegate?

    struct OverallOptions {
        var size: CGSize
        var align: MenuBarViewController.OverallAlign
        var insets: UIEdgeInsets

        init() {
            size = .zero
            align = .top
            insets = UIEdgeInsets.zero
        }
    }

    // MARK: - Handlers

    var addOverallLayer: ((UIView, OverallOptions) -> Void)?

    // MARK: - UI Controls

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 0)
        return chartView
    }()

    private let chartViewBackgroundLayer = UIView()

    private let topBorderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let bottomBorderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let stockPriceInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "300 $"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "-2,24 $ (12,43 %)"
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let buyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Buy for $300", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupStockPriceInfoView()
        setupChartView()
        setupButtons()
        setupBuyButton()
    }

    // MARK: - UI Actions

    private func setupChartView() {
        var options = OverallOptions()
        options.size = .init(width: Constants.deviceWidth, height: Constants.deviceHeight / 2)
        options.align = .top
        options.insets = .init(top: 60, left: 0, bottom: 0, right: 0)

        lineChartView.addSubview(topBorderLineView)
        constrain(topBorderLineView) { borderLineView in
            borderLineView.top == borderLineView.superview!.top
            borderLineView.height == 0.5
            borderLineView.width == borderLineView.superview!.width
        }

        lineChartView.addSubview(bottomBorderLineView)
        constrain(bottomBorderLineView) { borderLineView in
            borderLineView.bottom == borderLineView.superview!.bottom
            borderLineView.height == 0.5
            borderLineView.width == borderLineView.superview!.width
        }

        addOverallLayer?(lineChartView, options)
        view.addSubview(chartViewBackgroundLayer)
        constrain(chartViewBackgroundLayer, stockPriceInfoView) { chartViewBackgroundLayer, bar in
            chartViewBackgroundLayer.top == bar.bottom
            chartViewBackgroundLayer.height == Constants.deviceHeight / 2
        }
    }

    private func setupStockPriceInfoView() {
        view.addSubview(stockPriceInfoView)
        constrain(stockPriceInfoView) { view in
            view.top == view.superview!.top
            view.width == view.superview!.width
            view.height == 60
        }

        let stackView = UIStackView(arrangedSubviews: [currentPriceLabel, priceChangeLabel])
        stackView.axis = .vertical
        stockPriceInfoView.addSubview(stackView)
        constrain(stackView) { stackView in
            stackView.left == stackView.superview!.left + 20
            stackView.centerY == stackView.superview!.centerY
        }
    }

    private func setupButtons() {
        let buttonsStackView = makeButtonsStackView()
        view.addSubview(buttonsStackView)
        constrain(buttonsStackView, chartViewBackgroundLayer) { buttonsStackView, chartViewBackgroundLayer in
            buttonsStackView.top == chartViewBackgroundLayer.bottom + 20
            buttonsStackView.left == buttonsStackView.superview!.left + 20
            buttonsStackView.right == buttonsStackView.superview!.right - 20
            buttonsStackView.height == 30
        }
    }

    private func setupBuyButton() {
        var options = OverallOptions()
        options.size = .init(width: Constants.deviceWidth, height: 60)
        options.align = .bottom
        options.insets = .init(top: 0, left: 20, bottom: 40, right: 20)
        addOverallLayer?(buyButton, options)
    }

    // MARK: - Private Methods

    private func makeButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        for index in 0 ..< buttonTitles.count {
            let button = IntervalButton()
            button.configure(withTitle: buttonTitles[index])
            button.tag = index
            button.addTarget(self, action: #selector(intervalButtonClicked(sender:)), for: .touchUpInside)
            if index == activeInterval {
                button.isActive = true
            }
            buttonsArray.append(button)
            stackView.addArrangedSubview(button)
        }

        return stackView
    }

    private func makeChartDataEntry(prices: [Double]) -> [ChartDataEntry] {
        var yValues = [ChartDataEntry]()
        for (index, element) in prices.enumerated() {
            yValues.append(ChartDataEntry(x: Double(index), y: element))
        }
        return yValues
    }

    private func setNewPrice(withCurrentPrice current: Double, openPrice: Double) {
        buyButton.setTitle("Buy for $\(current)", for: .normal)
        currentPriceLabel.text = "$\(current)"
        priceChangeLabel.attributedText = Calculate.calculateDailyChange(currency: "USD", currentPrice: current, openPice: openPrice)
    }

    // MARK: - Selectors

    @objc private func intervalButtonClicked(sender: UIButton) {
        buttonsArray[activeInterval].isActive = false
        activeInterval = sender.tag
        if let button = sender as? IntervalButton {
            button.isActive = true
        }
        delegate?.intervalDidChange(newInterval: StockDetailViewModel.IntevalTime(rawValue: sender.tag) ?? .day)
    }

    // MARK: - ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }

    // MARK: - Public Methods

    func setData(withPrices prices: [Double], openPrice: Double) {
        let set1 = LineChartDataSet(entries: makeChartDataEntry(prices: prices))
        set1.drawCirclesEnabled = false
        set1.mode = .horizontalBezier
        set1.lineWidth = 2
        set1.setColor(.black)
        let gradientColors = [
            UIColor.white.cgColor,
            ChartColorTemplates.colorFromString("#DCDCDC").cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        set1.fillAlpha = 1
        set1.fill = .fillWithLinearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true

        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }

    // MARK: - Init

    init(barHeight: CGFloat = 0, activeInterval: Int, currentPrice: Double, openPrice: Double) {
        super.init(nibName: nil, bundle: nil)
        self.barHeight = barHeight
        self.activeInterval = activeInterval
        setNewPrice(withCurrentPrice: currentPrice, openPrice: openPrice)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
