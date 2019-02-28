//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupSelectOrCreateNetworkViewController: MeshSetupSelectNetworkViewController {

    override class var nibName: String {
        return "MeshSetupNetworkListWithCreateView"
    }

    @IBOutlet weak var createNetworkButton: MeshSetupAlternativeButton!
    



    override func setStyle() {
        super.setStyle()
        createNetworkButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.CreateOrSelectNetwork.Title
        createNetworkButton.setTitle(MeshSetupStrings.CreateOrSelectNetwork.CreateNetwork, for: .normal)
    }

    @IBAction func createNetworkButtonTapped(_ sender: Any) {
        self.callback(nil)

        ParticleSpinner.show(view)
        fadeContent()
        isBusy = true
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        ParticleSpinner.hide(view, animated: animated)
        unfadeContent(animated: animated)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        ParticleSpinner.show(view)
        fadeContent()
        isBusy = true
    }

    internal func fadeContent() {
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.titleLabel.alpha = 0.5
            self.networksTableView.alpha = 0.5

            self.createNetworkButton.alpha = 0.5
        }
    }

    internal func unfadeContent(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.titleLabel.alpha = 1
                self.networksTableView.alpha = 1

                self.createNetworkButton.alpha = 1
            }
        } else {
            self.titleLabel.alpha = 1
            self.networksTableView.alpha = 1

            self.createNetworkButton.alpha = 1

            self.view.setNeedsDisplay()
        }
    }
}
