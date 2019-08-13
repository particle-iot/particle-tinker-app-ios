//
// Created by Raimundas Sakalauskas on 2019-08-07.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceListFilterAndSortViewController: UIViewController {
    
    @IBOutlet weak var whiteBackground: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var sortByView: SortByView!
    @IBOutlet weak var deviceStatusView: DeviceStatusView!
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true) { }
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        self.sortByView.reset()
        self.deviceStatusView.reset()
    }
    
    @IBAction func showClicked(_ sender: Any) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
