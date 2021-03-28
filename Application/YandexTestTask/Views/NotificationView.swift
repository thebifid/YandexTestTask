//
//  NotificationView.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 21.03.2021.
//

import Cartography
import UIKit

/// Уведомление, выезжающее снизу экрана
class NotificationView: UIViewController {
    // MARK: - UI Controls

    private let notificationRectangle: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()

    private let icon = UIImageView()
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()

    // MARK: - Private Properties

    private weak var viewController: UIViewController?

    private var delayTime: Int = 1000

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Actions

    private func setupUI() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        view.addSubview(notificationRectangle)
        notificationRectangle.layer.cornerRadius = 8

        constrain(notificationRectangle) { notificationRectangle in

            notificationRectangle.height == 50
            notificationRectangle.width == notificationRectangle.superview!.width - 20

            notificationRectangle.top == notificationRectangle.superview!.top + 20
            notificationRectangle.centerX == notificationRectangle.superview!.centerX
        }

        notificationRectangle.addSubview(icon)

        constrain(icon) { icon in
            icon.width == 20
            icon.height == 20
            icon.left == icon.superview!.left + 20
            icon.top == icon.superview!.top + 15
        }

        notificationRectangle.addSubview(label)

        constrain(label, icon) { label, icon in
            label.left == icon.right + 10
            label.top == icon.top
        }
    }

    // MARK: - Enums

    enum TypeNotification {
        case success, failure
    }

    // MARK: - Public Methods

    func show(type: TypeNotification, withDelay delay: Int = 4000) {
        delayTime = delay
        configureNotification(type: type)

        guard let viewController = viewController else { return }
        viewController.addChild(self)
        viewController.view.addSubview(view)
        view.frame = .init(x: 0, y: viewController.view.frame.height, width: viewController.view.frame.width, height: 150)

        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame = .init(x: 0, y: viewController.view.frame.height - 100, width: viewController.view.frame.width, height: 150)
        }, completion: hideAction)
    }

    // MARK: - Private Methods

    private func configureNotification(type: TypeNotification) {
        switch type {
        case .success:
            notificationRectangle.backgroundColor = .green
            icon.image = R.image.s()
            label.text = "Success!"
        case .failure:
            notificationRectangle.backgroundColor = R.color.customLightRed()
            icon.image = R.image.x()
            label.text = "Failed to load data. Please try again"
        }
    }

    private lazy var hideAction: ((Bool) -> Void) = { _ in

        guard let viewController = self.viewController else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.delayTime)) {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame = .init(x: 0, y: viewController.view.frame.height, width: viewController.view.frame.width, height: 150)
            }, completion: self.removeHandler)
        }
    }

    private lazy var removeHandler: ((Bool) -> Void) = { _ in
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    // MARK: - Init

    init(to viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
