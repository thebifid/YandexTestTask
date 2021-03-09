//
//  StockChartViewController.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 08.03.2021.
//

import Cartography
import Charts
import UIKit

class StockChartViewController: UIViewController, ChartViewDelegate {
    private var barHeight: CGFloat = 0

    // MARK: - UI Controls

    var addOverallLayer: ((UIView, CGSize, MenuBarViewController.OverallAlign, UIEdgeInsets) -> Void)?

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        return chartView
    }()

    private let stockPriceInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let currentPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "300 $"
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.text = "-2,24 $ (12,43 %)"
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    var webSocketTask: URLSessionWebSocketTask?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        addOverallLayer?(lineChartView, .init(width: Constants.deviceWidth, height: Constants.deviceHeight / 2), .top, .init(top: 60, left: 0, bottom: 0, right: 0))
        super.viewDidLoad()
        view.backgroundColor = R.color.selectColor()
        setupStockPriceInfoView()
        setupLineChart()
    }

    // MARK: - UI Actions

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

    private func setupLineChart() {}

    // MARK: - ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }

    func setData(withPrices prices: [Double]) {
        let set1 = LineChartDataSet(entries: makeChartDataEntry(prices: prices), label: "Kekw")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 2
        set1.setColor(.black)
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }

    private func makeChartDataEntry(prices: [Double]) -> [ChartDataEntry] {
        var yValues = [ChartDataEntry]()
        for (index, element) in prices.enumerated() {
            yValues.append(ChartDataEntry(x: Double(index), y: element))
        }
        return yValues
    }

    init(barHeight: CGFloat = 0) {
        super.init(nibName: nil, bundle: nil)
        self.barHeight = barHeight
        print(barHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
