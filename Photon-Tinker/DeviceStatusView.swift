//
// Created by Raimundas Sakalauskas on 2019-08-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum DeviceStatusOptions: Int, CaseIterable, CustomStringConvertible {
    case online = 0
    case offline = 1


    var description: String {
        switch self {
            case .online:
                return "Online"
            case .offline:
                return "Offline"
        }
    }
}

protocol DeviceStatusViewDelegate: class {
    func deviceStatusOptionDidChange(deviceStatusView: DeviceStatusView, options: [DeviceStatusOptions])
}

class DeviceStatusView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: DeviceStatusViewDelegate?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var selectedOptions: [DeviceStatusOptions] {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            var selectedOptions: [DeviceStatusOptions] = []

            for item in selectedItems {
                selectedOptions.append(DeviceStatusOptions(rawValue: item.row)!)
            }

            return selectedOptions
        } else {
            return []
        }
    }

    func setup(selectedOptions: [DeviceStatusOptions]?) {
        if let selectedOptions = selectedOptions {
            for option in selectedOptions {
                collectionView.selectItem(at: IndexPath(row: option.rawValue, section: 0), animated: false, scrollPosition: .top)
            }
        } else {
            collectionView.deselectAllItems(animated: false)
        }
    }

    func reset() {
        collectionView.deselectAllItems(animated: true)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.allowsMultipleSelection = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DeviceStatusOptions.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceStatusCell", for: indexPath) as! FilterDeviceOnlineStatusCell
        cell.setup(option: DeviceStatusOptions(rawValue: indexPath.row)!)
        return cell
    }



    override func layoutSubviews() {
        super.layoutSubviews()

        self.heightConstraint.constant = collectionView.contentSize.height
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width - 10) / 2, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.deviceStatusOptionDidChange(deviceStatusView: self, options: self.selectedOptions)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.delegate?.deviceStatusOptionDidChange(deviceStatusView: self, options: self.selectedOptions)
    }

}
