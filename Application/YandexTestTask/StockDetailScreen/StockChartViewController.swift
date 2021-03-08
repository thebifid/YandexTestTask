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
    // MARK: - UI Controls

    private lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        return chartView
    }()

    var webSocketTask: URLSessionWebSocketTask?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.selectColor()
        setupLineChart()
        setData()
    }

    // MARK: - UI Actions

    private func setupLineChart() {
        view.addSubview(lineChartView)
        constrain(lineChartView) { lineChartView in
            lineChartView.center == lineChartView.superview!.center
            lineChartView.width == lineChartView.superview!.width
            lineChartView.height == 400
        }
    }

    // MARK: - ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }

    private func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Kekw")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.lineWidth = 2
        set1.setColor(.black)
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }

    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0, y: 458.56),
        ChartDataEntry(x: 1, y: 459.58),
        ChartDataEntry(x: 2, y: 459),
        ChartDataEntry(x: 3, y: 461.49),
        ChartDataEntry(x: 4, y: 445.85),
        ChartDataEntry(x: 5, y: 435.85),
        ChartDataEntry(x: 6, y: 465.85)
    ]
}
