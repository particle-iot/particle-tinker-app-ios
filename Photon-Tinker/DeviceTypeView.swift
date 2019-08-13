//
// Created by Raimundas Sakalauskas on 2019-08-08.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

enum DeviceTypeOptions: Int, CaseIterable, CustomStringConvertible {
    case boron = 0
    case electron
    case argon
    case photon
    case xenon
    case other


    var description: String {
        switch self {
            case .boron:
                return "Boron / B SoM"
            case .electron:
                return "Electron / E SoM"
            case .argon:
                return "Argon"
            case .photon:
                return "Photon"
            case .xenon:
                return "Xenon"
            case .other:
                return "Other"
        }
    }
}

protocol DeviceTypeViewDelegate: class {
    func deviceTypeOptionDidChange(deviceTypeView: DeviceTypeView, options: [DeviceTypeOptions])
}

class DeviceTypeView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: DeviceTypeViewDelegate?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var selectedOptions: [DeviceTypeOptions] {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            var selectedOptions: [DeviceTypeOptions] = []

            for item in selectedItems {
                selectedOptions.append(DeviceTypeOptions(rawValue: item.row)!)
            }

            return selectedOptions
        } else {
            return []
        }
    }

    func setup(selectedOptions: [DeviceTypeOptions]?) {
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
        return DeviceTypeOptions.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deviceTypeCell", for: indexPath) as! FilterDeviceTypeCell
        cell.setup(option: DeviceTypeOptions(rawValue: indexPath.row)!)
        return cell
    }



    override func layoutSubviews() {
        super.layoutSubviews()

        self.heightConstraint.constant = collectionView.contentSize.height
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width - 10) / 2, height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.deviceTypeOptionDidChange(deviceTypeView: self, options: self.selectedOptions)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.delegate?.deviceTypeOptionDidChange(deviceTypeView: self, options: self.selectedOptions)
    }

}
