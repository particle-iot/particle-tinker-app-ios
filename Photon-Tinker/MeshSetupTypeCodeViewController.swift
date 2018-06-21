//
//  MeshSetupTypeCodeViewController.swift
//  Particle
//
//  Created by Ido Kleinman on 6/20/18.
//  Copyright © 2018 spark. All rights reserved.
//

import UIKit

protocol MeshSetupTypeCodeDelegate {
    func didTypeCode(code : String)
}

class MeshSetupTypeCodeViewController: MeshSetupViewController {
    var delegate : MeshSetupTypeCodeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBAction func pairButtonTapped(_ sender: Any) {
        self.delegate?.didTypeCode(code: self.codeTextField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
