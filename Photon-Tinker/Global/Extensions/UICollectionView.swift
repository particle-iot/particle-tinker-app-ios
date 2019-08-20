//
// Created by Raimundas Sakalauskas on 2019-08-13.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}
