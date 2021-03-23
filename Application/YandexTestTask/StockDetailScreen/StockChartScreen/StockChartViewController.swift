//
//  StockChartViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Cartography
import Charts
import MaterialComponents.MDCActivityIndicator
import UIKit

protocol IntervalDelegate: AnyObject {
    func intervalDidChange(newInterval interval: StockChartViewModel.IntevalTime)
}

class StockChartViewController: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - Private Properties

    private let viewModel: StockChartViewModel!
    private var barHeight: CGFloat = 0
    private let buttonTitles = ["D", "W", "M", "6M", "1Y", "ALL"]
    private var buttonsArray = [IntervalButton]()
    private var set1 = LineChartDataSet()
    private var isDrawVerticalHighlightIndicatorEnabled: Bool = true

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

    /// Описано в MenuBarViewController
    var addOverallLayer: ((UIView, OverallOptions) -> Void)?

    // MARK: - UI Controls

    private let markerView = DotMarkerView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))

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
        chartView.noDataText = ""
        chartView.marker = markerView
        let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pressed(sender:)))
        pressRecognizer.delegate = self
        pressRecognizer.minimumPressDuration = 0
        chartView.addGestureRecognizer(pressRecognizer)
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
        label.font = R.font.montserratBold(size: 24)
        return label
    }()

    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "-2,24 $ (12,43 %)"
        label.font = R.font.montserratMedium(size: 14)
        return label
    }()

    private let buyButton = BuyButton()

    private let detailDataLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratMedium(size: 14)
        label.textColor = .lightGray
        return label
    }()

    private let detailPriceLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.montserratBold(size: 18)
        label.textColor = .black
        return label
    }()

    private lazy var datailInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [detailDataLabel, detailPriceLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alpha = 0
        stackView.alignment = .center
        return stackView
    }()

    private let activityIndicator: MDCActivityIndicator = {
        let ai = MDCActivityIndicator()
        return ai
    }()

    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.refresh(), for: .normal)
        return button
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        enableBinding()
        setupStockPriceInfoView()
        setupChartView()
        setupButtons()
        setupBuyButton()
        requestCompanyCandles()
        viewModel.connectWebSocket()
        setNewPrice(withCurrentPrice: viewModel.currentPrice, previousClose: viewModel.previousClose)
        setupRefreshButton()
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

        lineChartView.addSubview(activityIndicator)
        constrain(activityIndicator) { activityIndicator in
            activityIndicator.center == activityIndicator.superview!.center
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

        stockPriceInfoView.addSubview(datailInfoStackView)
        constrain(datailInfoStackView) { datailInfoStackView in
            datailInfoStackView.center == datailInfoStackView.superview!.center
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

    private func setupRefreshButton() {
        stockPriceInfoView.addSubview(refreshButton)
        refreshButton.addTarget(self, action: #selector(refreshButtonDidClicked), for: .touchUpInside)
        refreshButton.isHidden = true
        constrain(refreshButton) { refreshButton in
            refreshButton.centerY == refreshButton.superview!.centerY
            refreshButton.right == refreshButton.superview!.right - 20
            refreshButton.height == 40
            refreshButton.width == 40
        }
    }

    // MARK: - Private Methods

    private func requestCompanyCandles() {
        activityIndicator.startAnimating()
        refreshButton.isHidden = true
        viewModel.requestCompanyCandles { [weak self] result in
            switch result {
            case .failure:
                DispatchQueue.main.async {
                    self?.refreshButton.isHidden = false
                    self?.activityIndicator.stopAnimating()
                }
            case .success:
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func enableBinding() {
        viewModel.didUpdateCandles = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setData(withPrices: self.viewModel.candles,
                             openPrice: self.viewModel.previousClose)
                self.setNewPrice(withCurrentPrice: self.viewModel.currentPrice,
                                 previousClose: self.viewModel.previousClose)
                self.activityIndicator.stopAnimating()
                self.refreshButton.isHidden = true
            }
        }
    }

    private func makeButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        for index in 0 ..< buttonTitles.count {
            let button = IntervalButton()
            button.configure(withTitle: buttonTitles[index])
            button.tag = index
            button.addTarget(self, action: #selector(intervalButtonClicked(sender:)), for: .touchUpInside)
            if index == viewModel.activeInterval.rawValue {
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

    private func intervalDidChange(newInterval interval: StockChartViewModel.IntevalTime) {
        activityIndicator.startAnimating()
        setData(withPrices: [],
                openPrice: 0)
        setNewPrice(withCurrentPrice: 0,
                    previousClose: 0)
        viewModel.setActiveInterval(withNewInterval: interval)
    }

    private func setNewPrice(withCurrentPrice current: Double, previousClose: Double) {
        buyButton.configure(withTitle: "Buy for \(String(current).withCurrency(currency: viewModel.currency))")
        currentPriceLabel.text = "\(current)".withCurrency(currency: viewModel.currency)
        priceChangeLabel.attributedText = Calculate.calculateDailyChange(currency: "USD",
                                                                         currentPrice: current,
                                                                         previousClose: previousClose)
    }

    private func setData(withPrices prices: [Double], openPrice: Double) {
        set1 = LineChartDataSet(entries: makeChartDataEntry(prices: prices))
        set1.drawCirclesEnabled = false
        set1.mode = .horizontalBezier
        set1.lineWidth = 2
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = isDrawVerticalHighlightIndicatorEnabled
        set1.highlightColor = .black
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

    @objc private func refreshButtonDidClicked() {
        requestCompanyCandles()
    }

    // MARK: - Selectors

    @objc private func intervalButtonClicked(sender: UIButton) {
        buttonsArray[viewModel.activeInterval.rawValue].isActive = false
        if let button = sender as? IntervalButton {
            button.isActive = true
        }
        intervalDidChange(newInterval: StockChartViewModel.IntevalTime(rawValue: sender.tag) ?? .day)
    }

    @objc private func pressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let h = lineChartView.getHighlightByTouchPoint(sender.location(in: lineChartView))
            lineChartView.highlightValue(h, callDelegate: true)

            UIView.animate(withDuration: 0.1) {
                self.markerView.alpha = 1
                self.currentPriceLabel.alpha = 0
                self.priceChangeLabel.alpha = 0
                self.datailInfoStackView.alpha = 1
                self.isDrawVerticalHighlightIndicatorEnabled = true
                self.set1.drawVerticalHighlightIndicatorEnabled = true
            }
        case .ended:
            UIView.animate(withDuration: 0.1) {
                self.markerView.alpha = 0
                self.currentPriceLabel.alpha = 1
                self.priceChangeLabel.alpha = 1
                self.datailInfoStackView.alpha = 0
                self.set1.drawVerticalHighlightIndicatorEnabled = false
                self.isDrawVerticalHighlightIndicatorEnabled = false
                self.lineChartView.setNeedsDisplay()
            }

        default:
            break
        }
    }

    // MARK: - ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        detailPriceLabel.text = String(entry.y).withCurrency(currency: viewModel.currency)
        detailDataLabel.text = viewModel.dateForCandle(forIndex: Int(entry.x))
    }

    // MARK: - Gesture Recognizer Delegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Init

    init(barHeight: CGFloat = 0, viewModel: StockChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.barHeight = barHeight
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Deinit

    deinit {
        viewModel.disconnectWebSocket()
    }
}
