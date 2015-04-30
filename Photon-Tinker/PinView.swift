//
//  PinView.swift
//  
//
//  Created by Ido on 4/28/15.
//
//

import UIKit

//@IBDesignable
@objc class PinView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
//    @IBInspectable @IBOutlet weak var label: UILabel!
//    @IBInspectable @IBOutlet weak var pinOuterButton: UIButton!
//    @IBInspectable @IBOutlet weak var pinInnerButton: UIButton!
//    @IBInspectable @IBOutlet weak var backgroundView: UIView!
//    @IBInspectable @IBOutlet weak var analogValueLabel: UILabel!
//    @IBInspectable @IBOutlet weak var digitalStateLabel: UILabel!
//    @IBInspectable @IBOutlet weak var analogSlider: UISlider!

    
 
    
    func instanceFromNib(sender : AnyObject) -> UIView {
        return UINib(nibName: "PinView", bundle: nil).instantiateWithOwner(sender, options: nil)[0] as! UIView
    }
    
    
    required init()
    {
        super.init()
    }
    
    convenience init(side: SPKCorePinSide)
    {
        super.init()
        
        
    }
    
 
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

//    func init(coder aDecoder: NSCoder) {
//        if let self = super.init(coder aDecoder)
//        {
//            self.addSubview(NSBundle.mainBundle().loadNibNamed("PinView", owner: self, options: nil))
//        }
//    }

    
}
