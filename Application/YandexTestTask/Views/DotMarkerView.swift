//
//  DotMarkerView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 14.03.2021.
//

import Cartography
import Charts

/// Точка для графика (отображется когда пользователь нажимает на график)
public class DotMarkerView: MarkerView {
    // MARK: - UI Controls

    private lazy var dotView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = self.frame.height / 4
        return view
    }()

    private lazy var markerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = self.frame.height / 2
        return view
    }()

    // MARK: - Public Methods

    override public func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        layoutIfNeeded()
    }

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(markerView)
        markerView.addSubview(dotView)
        constrain(markerView, dotView) { markerView, dotView in
            markerView.edges == markerView.superview!.edges
            dotView.center == markerView.center
            dotView.size == markerView.size / 2
        }

        offset.x = -self.frame.size.width / 2.0
        offset.y = -self.frame.size.height / 2.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
