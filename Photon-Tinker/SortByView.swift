//
// Created by Raimundas Sakalauskas on 2019-08-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum DeviceListSortingOptions: Int, CaseIterable, CustomStringConvertible {
    case onlineStatus = 0
    case deviceType
    case name
    case lastHeard

    var description: String {
        switch self {
            case .onlineStatus:
                return "Online Status"
            case .deviceType:
                return "Device Type"
            case .name:
                return "Name"
            case .lastHeard:
                return "Last Heard"
        }
    }
}

protocol SortByViewDelegate: class {
    func sortOptionDidChange(sortByView: SortByView, option: DeviceListSortingOptions)
}

class SortByView: UIView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SortByViewDelegate?

    var heightConstraint: NSLayoutConstraint!

    var selectedSortOption: DeviceListSortingOptions {
        return DeviceListSortingOptions(rawValue: self.tableView.indexPathForSelectedRow!.row)!
    }

    func setup(selectedSortOption: DeviceListSortingOptions) {
        self.tableView.selectRow(at: IndexPath(row: selectedSortOption.rawValue, section: 0), animated: false, scrollPosition: .none)
    }

    func reset() {
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.tableView.separatorStyle = .none
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)

        heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 100)
        heightConstraint.isActive = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeviceListSortingOptions.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath) as! SortTypeListTableViewCell
        cell.setup(option: DeviceListSortingOptions(rawValue: indexPath.row)!)
        return cell
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.heightConstraint.constant = tableView.contentSize.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.sortOptionDidChange(sortByView: self, option: self.selectedSortOption)

    }
}
