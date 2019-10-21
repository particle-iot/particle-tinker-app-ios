//
// Created by Raimundas Sakalauskas on 2019-08-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum DeviceOnlineStatusOptions: Int, CaseIterable, CustomStringConvertible {
    case online = 0
    case offline = 1


    var description: String {
        switch self {
            case .online:
                return TinkerStrings.Filters.DeviceStatus.Online
            case .offline:
                return TinkerStrings.Filters.DeviceStatus.Offline
        }
    }

    func match(device: ParticleDevice) -> Bool {
        switch self {
            case .online:
                return device.connected == true
            case .offline:
                return device.connected == false
        }
    }
}

protocol DeviceStatusViewDelegate: class {
    func deviceStatusOptionDidChange(deviceStatusView: DeviceStatusView, options: [DeviceOnlineStatusOptions])
}

class DeviceStatusView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: DeviceStatusViewDelegate?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var selectedOptions: [DeviceOnlineStatusOptions] {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            var selectedOptions: [DeviceOnlineStatusOptions] = []

            for item in selectedItems {
                selectedOptions.append(DeviceOnlineStatusOptions(rawValue: item.row)!)
            }

            return selectedOptions
        } else {
            return []
        }
    }

    func setup(selectedOptions: [DeviceOnlineStatusOptions]?) {
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
        self.delegate?.deviceStatusOptionDidChange(deviceStatusView: self, options: self.selectedOptions)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.allowsMultipleSelection = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DeviceOnlineStatusOptions.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceStatusCell", for: indexPath) as! FilterDeviceOnlineStatusCell
        cell.setup(option: DeviceOnlineStatusOptions(rawValue: indexPath.row)!)
        return cell
    }



    override func layoutSubviews() {
        super.layoutSubviews()

        self.heightConstraint.constant = collectionView.contentSize.height
        self.collectionView.collectionViewLayout.invalidateLayout()
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
