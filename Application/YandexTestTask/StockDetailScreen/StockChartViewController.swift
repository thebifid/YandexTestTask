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

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        return chartView
    }()

    private let stockPriceInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()

    var webSocketTask: URLSessionWebSocketTask?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.selectColor()
        setupStockPriceInfoView()
        setupLineChart()
    }

    // MARK: - UI Actions

    private func setupStockPriceInfoView() {
        view.addSubview(stockPriceInfoView)
        constrain(stockPriceInfoView) { view in
            view.top == view.superview!.safeAreaLayoutGuide.top + barHeight
            view.width == view.superview!.width
            view.height == 90
        }
    }

    private func setupLineChart() {
        view.addSubview(lineChartView)
        constrain(lineChartView, stockPriceInfoView) { lineChartView, bar in
            lineChartView.top == bar.bottom
            lineChartView.width == lineChartView.superview!.width
            lineChartView.height == 400
        }
    }

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
