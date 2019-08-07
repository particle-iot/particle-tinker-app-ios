//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
