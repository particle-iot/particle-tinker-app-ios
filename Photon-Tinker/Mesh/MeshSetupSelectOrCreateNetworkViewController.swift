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

        self.fade()
    }

    override func resume(animated: Bool) {
        super.resume(animated: animated)

        ParticleSpinner.hide(view, animated: animated)
        unfadeContent(animated: animated)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        self.fade()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addFadableViews()
    }

    private func addFadableViews() {
        if viewsToFade == nil {
            viewsToFade = [UIView]()
        }

        viewsToFade!.append(titleLabel)
        viewsToFade!.append(networksTableView)
        viewsToFade!.append(createNetworkButton)
    }



}
