//
// MenuDrawerViewController.swift
// Particle
//
// A left slide-out navigation drawer for the device list. Shows the logged-in
// account, quick links, a log-out action and the app version/build in the footer.
//

import UIKit

class MenuDrawerViewController: UIViewController {

    /// Called when the user confirms log out. The presenter performs the actual logout.
    var onLogOut: (() -> Void)?

    private let panelWidth: CGFloat = min(300, UIScreen.main.bounds.width * 0.82)

    private let backdrop = UIControl()
    private let panel = UIView()
    private var panelLeading: NSLayoutConstraint!

    private let headerColor = UIColor(rgb: 0x1B1F2A)
    private let accentColor = ParticleUtils.particleCyanColor

    private struct Link {
        let title: String
        let symbol: String
        let url: String
    }

    // Quick links shown between the account header and the log-out row.
    private let links: [Link] = [
        Link(title: "Documentation", symbol: "book", url: "https://docs.particle.io"),
        Link(title: "Console", symbol: "globe", url: "https://console.particle.io"),
        Link(title: "Privacy Policy", symbol: "hand.raised", url: "https://www.particle.io/legal/privacy/"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBackdrop()
        setupPanel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Slide the panel in and fade the backdrop the first time we appear.
        guard panelLeading.constant < 0 else { return }
        panelLeading.constant = 0
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut) {
            self.backdrop.backgroundColor = UIColor.black.withAlphaComponent(0.45)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Setup

    private func setupBackdrop() {
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.backgroundColor = .clear
        backdrop.addTarget(self, action: #selector(backdropTapped), for: .touchUpInside)
        view.addSubview(backdrop)
        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupPanel() {
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = .white
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.2
        panel.layer.shadowRadius = 8
        panel.layer.shadowOffset = CGSize(width: 2, height: 0)
        view.addSubview(panel)

        panelLeading = panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -panelWidth)
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: view.topAnchor),
            panel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panel.widthAnchor.constraint(equalToConstant: panelWidth),
            panelLeading,
        ])

        let header = makeHeader()
        let rowsStack = makeRows()
        let footer = makeFooter()

        for v in [header, rowsStack, footer] {
            v.translatesAutoresizingMaskIntoConstraints = false
            panel.addSubview(v)
        }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: panel.topAnchor),
            header.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: panel.trailingAnchor),

            rowsStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            rowsStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            rowsStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor),

            footer.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            footer.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            footer.bottomAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    private func makeHeader() -> UIView {
        let container = UIView()
        container.backgroundColor = headerColor

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "PARTICLE"
        title.textColor = .white
        title.font = ParticleUtils.particleBoldFont.withSize(20)
        title.adjustsFontSizeToFitWidth = true

        let email = UILabel()
        email.translatesAutoresizingMaskIntoConstraints = false
        email.text = ParticleCloud.sharedInstance().loggedInUsername ?? ""
        email.textColor = UIColor.white.withAlphaComponent(0.7)
        email.font = ParticleUtils.particleRegularFont.withSize(13)
        email.adjustsFontSizeToFitWidth = true
        email.minimumScaleFactor = 0.7

        container.addSubview(title)
        container.addSubview(email)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            title.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),

            email.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            email.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            email.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            email.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])
        return container
    }

    private func makeRows() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 0

        for (index, link) in links.enumerated() {
            stack.addArrangedSubview(makeRow(title: link.title, symbol: link.symbol, destructive: false, tag: index))
        }

        let separator = UIView()
        separator.backgroundColor = ParticleUtils.particleLightGrayColor.withAlphaComponent(0.5)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let sepWrap = UIView()
        sepWrap.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: sepWrap.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: sepWrap.trailingAnchor, constant: -20),
            separator.topAnchor.constraint(equalTo: sepWrap.topAnchor, constant: 8),
            separator.bottomAnchor.constraint(equalTo: sepWrap.bottomAnchor, constant: -8),
        ])
        stack.addArrangedSubview(sepWrap)

        let logout = makeRow(title: TinkerStrings.Action.LogOut, symbol: "arrow.right.square", destructive: true, tag: -1)
        stack.addArrangedSubview(logout)

        return stack
    }

    private func makeRow(title: String, symbol: String, destructive: Bool, tag: Int) -> UIControl {
        let row = RowControl()
        row.tag = tag
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let tint = destructive ? ParticleUtils.particlePomegranateColor : ParticleUtils.particleDarkGrayColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = destructive ? ParticleUtils.particlePomegranateColor : accentColor

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = tint
        label.font = ParticleUtils.particleRegularFont.withSize(16)

        row.addSubview(icon)
        row.addSubview(label)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        if destructive {
            row.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        } else {
            row.addTarget(self, action: #selector(linkTapped(_:)), for: .touchUpInside)
        }
        return row
    }

    private func makeFooter() -> UILabel {
        let label = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        label.text = "Tinker \(version) (\(build))"
        label.textColor = ParticleUtils.particleGrayColor
        label.font = ParticleUtils.particleRegularFont.withSize(12)
        return label
    }

    // MARK: - Actions

    @objc private func linkTapped(_ sender: UIControl) {
        guard sender.tag >= 0, sender.tag < links.count, let url = URL(string: links[sender.tag].url) else { return }
        dismissDrawer {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc private func logOutTapped() {
        let confirm = UIAlertController(
            title: TinkerStrings.DeviceList.Prompt.LogOutConfirmation.Title,
            message: TinkerStrings.DeviceList.Prompt.LogOutConfirmation.Message,
            preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: TinkerStrings.Action.Cancel, style: .cancel))
        confirm.addAction(UIAlertAction(title: TinkerStrings.Action.LogOut, style: .destructive) { [weak self] _ in
            self?.dismissDrawer {
                self?.onLogOut?()
            }
        })
        present(confirm, animated: true)
    }

    @objc private func backdropTapped() {
        dismissDrawer(completion: nil)
    }

    private func dismissDrawer(completion: (() -> Void)?) {
        panelLeading.constant = -panelWidth
        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseIn, animations: {
            self.backdrop.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }
}

/// A button-like container that highlights on touch-down.
private class RowControl: UIControl {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(rgb: 0x000000, alpha: 0.06) : .clear
        }
    }
}
