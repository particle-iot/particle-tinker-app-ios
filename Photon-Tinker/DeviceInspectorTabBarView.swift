//
// Created by Raimundas Sakalauskas on 2019-04-24.
// (c).*(Particle). All rights reserved.
//

import Foundation


class DeviceInspectorTabBarView : UIControl {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var highlightView: UIView!
    
    @IBOutlet var tabs: [UIButton]!

    private let normalFont: UIFont = UIFont(name: "Gotham-Book", size: 15.0)!
    private let normalColor: UIColor = UIColor(rgb: 0x999990)

    private let selectedFont: UIFont = UIFont(name: "Gotham-Medium", size: 15.0)!
    private let selectedColor: UIColor = UIColor(rgb: 0x262626)

    private var centerConstraint: NSLayoutConstraint!

    private(set) public var selectedIdx: Int = 0 {
        didSet {
            self.sendActions(for: .valueChanged)
        }
    }

    func setup(tabNames: [String]) {
        while tabs.count > tabNames.count {
            tabs.popLast()!.removeFromSuperview()
        }

        for i in 0 ..< tabNames.count {
            tabs[i].tag = i

            tabs[i].setAttributedTitle(NSAttributedString(string: tabNames[i], attributes: [
                NSAttributedString.Key.font: normalFont,
                NSAttributedString.Key.foregroundColor: normalColor
            ]), for: .normal)

            tabs[i].setAttributedTitle(NSAttributedString(string: tabNames[i], attributes: [
                NSAttributedString.Key.font: normalFont,
                NSAttributedString.Key.foregroundColor: selectedColor
            ]), for: .highlighted)

            tabs[i].setAttributedTitle(NSAttributedString(string: tabNames[i], attributes: [
                NSAttributedString.Key.font: selectedFont,
                NSAttributedString.Key.foregroundColor: selectedColor
            ]), for: .selected)

            tabs[i].addTarget(self, action: #selector(tabTapped), for: .touchUpInside)
        }

        tabs[0].isSelected = true
        centerConstraint = highlightView.centerXAnchor.constraint(equalTo: tabs[self.selectedIdx].centerXAnchor, constant: 0)

        NSLayoutConstraint.activate([
            highlightView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0 / CGFloat(tabs.count)),
            centerConstraint
        ])
    }

    @objc func tabTapped(sender: UIButton) {
        tabs[selectedIdx].isSelected = false
        selectedIdx = sender.tag
        tabs[selectedIdx].isSelected = true

        UIView.animate(withDuration: 0.25) { [weak self] in
            if let self = self {
                self.centerConstraint.isActive = false
                self.removeConstraint(self.centerConstraint)

                self.centerConstraint = self.highlightView.centerXAnchor.constraint(equalTo: self.tabs[self.selectedIdx].centerXAnchor, constant: 0)
                self.centerConstraint.isActive = true

                self.layoutIfNeeded()
            }
        }
    }
}
