//
//  DeviceInspectorChildViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/29/16.
//  Copyright © 2016 Particle. All rights reserved.
//

protocol DeviceInspectorChildViewControllerDelegate: class {
    func childViewDidRequestDataRefresh(_ childView: DeviceInspectorChildViewController)
}

class DeviceInspectorChildViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: DeviceInspectorChildViewControllerDelegate?
    weak var device : ParticleDevice!

    var refreshControl: UIRefreshControl!

    var isRefreshing: Bool {
        return refreshControl.isRefreshing
    }

    func setup(device: ParticleDevice) {
        self.device = device
    }

    override func viewDidAppear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .alwaysHide;

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared().previousNextDisplayMode = .default

        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 13.0, *) {
            if self.responds(to: Selector("overrideUserInterfaceStyle")) {
                self.setValue(UIUserInterfaceStyle.light.rawValue, forKey: "overrideUserInterfaceStyle")
            }
        }
    }

    func showTutorial() {
        assert(false, "This method must be overriden by the DeviceInspectorChildViewController subclass")
    }

    func resetUserAppData() {

    }

    func update() {

    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ParticleStyle.SecondaryTextColor
        refreshControl.addTarget(self, action:  #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    @objc func refreshData(sender: UIRefreshControl) {
        self.tableView.isUserInteractionEnabled = false
        self.tableView.panGestureRecognizer.isEnabled = false
        self.tableView.panGestureRecognizer.isEnabled = true

        self.delegate?.childViewDidRequestDataRefresh(self)
    }

    func adjustTableViewHeaderViewConstraints() {
        if (self.tableView.tableHeaderView == nil) {
            return
        }

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.heightAnchor, constant: -8),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.widthAnchor),
                self.tableView.tableHeaderView!.centerXAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.centerXAnchor),
                self.tableView.tableHeaderView!.centerYAnchor.constraint(equalTo: self.tableView.safeAreaLayoutGuide.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.heightAnchor, constant: -8),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.widthAnchor),
                self.tableView.tableHeaderView!.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor),
                self.tableView.tableHeaderView!.centerYAnchor.constraint(equalTo: self.tableView.centerYAnchor)
            ])
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    //MARK: Keyboard display
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height - self.view.safeAreaInsets.bottom - 100, 0)
            } else {
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height - 100, 0)
            }

            UIView.animate(withDuration: 0.25) { () -> Void in
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc  func keyboardWillHide(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            } else {
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            }

            UIView.animate(withDuration: 0.25) { () -> Void in
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}
