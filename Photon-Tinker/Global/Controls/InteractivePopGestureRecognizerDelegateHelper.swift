//
// Created by Raimundas Sakalauskas on 2019-08-01.
// Copyright (c) 2019 Particle. All rights reserved.
//
// https://stackoverflow.com/questions/24710258/no-swipe-back-when-hiding-navigation-bar-in-uinavigationcontroller


class InteractivePopGestureRecognizerDelegateHelper: NSObject, UIGestureRecognizerDelegate {

    var navigationController: UINavigationController
    var minViewControllers: Int
    var isEnabled: Bool = true

    init(controller: UINavigationController, minViewControllers: Int = 1) {
        self.navigationController = controller
        self.minViewControllers = minViewControllers
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.isEnabled else { return false }

        if (navigationController.viewControllers.count > self.minViewControllers) {
            if let vc = navigationController.viewControllers.last as? MeshSetupViewController {
                return vc.allowBack && !vc.isBusy
            } else {
                return true
            }
        }
        return false
    }

    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}