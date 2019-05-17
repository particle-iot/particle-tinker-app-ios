//
// Created by Raimundas Sakalauskas on 2019-05-13.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class DeviceInspectorTinkerViewController: DeviceInspectorChildViewController {

    @IBOutlet weak var functionView: PinFunctionView!

    @IBOutlet weak var functionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var functionViewCenterYConstraint: NSLayoutConstraint!

    @IBOutlet var tinkerView: UIView!
    @IBOutlet var flashTinkerView: UIView!
    @IBOutlet var deviceOfflineView: UIView!
    
    private var flashStarted: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addRefreshControl()
    }

    override func setup(device: ParticleDevice) {
        super.setup(device: device)
    }

    override func update() {
        super.update()

        self.tableView.isUserInteractionEnabled = true
        self.refreshControl.endRefreshing()

        self.tableView.tableHeaderView = nil
        self.flashTinkerView.removeFromSuperview()
        self.tinkerView.removeFromSuperview()
        self.deviceOfflineView.removeFromSuperview()

        if (self.device.connected) {
            if (self.device.isRunningTinker()) {
                self.tableView.tableHeaderView = self.tinkerView
            } else {
                self.tableView.tableHeaderView = self.flashTinkerView
            }
        } else {
            self.tableView.tableHeaderView = self.deviceOfflineView
        }

        if #available(iOS 11, *) {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.tableView.tableHeaderView!.heightAnchor.constraint(equalTo: self.tableView.heightAnchor),
                self.tableView.tableHeaderView!.widthAnchor.constraint(equalTo: self.tableView.widthAnchor)
            ])
        }
    }

    override func resetUserAppData() {
        super.resetUserAppData()

        self.flashStarted = false
    }

    override func showTutorial() {

    }
}



//
//    private var pinViews: Dictionary<String, PinView>!
//    private var originalPinFunctionFrame: CGRect!
//
//    private var pinViewShowingSlider: PinView?


//{
//        self.device.configurePins()
//
//        pinViews = Dictionary()
//
//        // add chip shadow
//        var chipShadowImageView = UIImageView(image: UIImage(named: "imgDeviceShadow")!.withRenderingMode(.alwaysTemplate))
//        chipShadowImageView.translatesAutoresizingMaskIntoConstraints = false
//        chipShadowImageView.tintColor = UIColor(white: 0.2, alpha: 0.5)
//        chipShadowImageView.contentMode = .scaleToFill
//
//        chipView.insertSubview(chipShadowImageView, belowSubview: functionView)
//        NSLayoutConstraint.activate([
//            chipShadowImageView.leftAnchor.constraint(equalTo: chipView.leftAnchor),
//            chipShadowImageView.bottomAnchor.constraint(equalTo: chipView.bottomAnchor),
//            chipShadowImageView.topAnchor.constraint(equalTo: chipView.topAnchor),
//            chipShadowImageView.rightAnchor.constraint(equalTo: chipView.rightAnchor)
//        ])
//
//        //setup pins
//        let xOffset: CGFloat = 6
//        let chipBottomMargin: CGFloat = chipView.frame.size.height / 14
//
//        for pin in device.pins! {
//            var pinView = PinView(pin: pin)
//            pinView.translatesAutoresizingMaskIntoConstraints = false
//
//            var ySpacing: CGFloat = (chipShadowImageView.frame.size.height - chipBottomMargin) / CGFloat(device.pins!.count / 2) // assume even amount of pins per row
//            ySpacing = max(ySpacing, pinView.frame.size.height)
//            var yOffset: CGFloat = chipShadowImageView.frame.origin.y + 8
//
//            chipView.insertSubview(pinView, aboveSubview: chipShadowImageView)
//
//
//            var xPosAttribute = (pin.side == .left) ? NSLayoutConstraint.Attribute.leading : NSLayoutConstraint.Attribute.trailing
//            var xConstant = (pin.side == .left) ? xOffset : -xOffset
//
//            chipView.addConstraint(NSLayoutConstraint(item: pinView, attribute: xPosAttribute, relatedBy: .equal, toItem: chipView, attribute: xPosAttribute, multiplier: 1.0, constant: xConstant))
//            chipView.addConstraint(NSLayoutConstraint(item: pinView, attribute: .top, relatedBy: .equal, toItem: chipView, attribute: .top, multiplier: 1.0, constant: CGFloat(pin.row) * ySpacing + yOffset))
//            pinView.addConstraint(NSLayoutConstraint(item: pinView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: pinView.bounds.size.width)) //50
//            pinView.addConstraint(NSLayoutConstraint(item: pinView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: pinView.bounds.size.height)) //50
//
//            pinView.delegate = self
//            pinViews[pin.label] = pinView


            // Pin Value View
//                var pinValueView = PinValueView(pin: pin)
//                chipView.insertSubview(pinValueView, aboveSubview: chipShadowImageView)
//                pinValueView.translatesAutoresizingMaskIntoConstraints = false

            // stick view to right of the pin when positioned in left or exact opposite
//                var pinValueViewXPosAttribute = xPosAttribute
//                var invPinValueViewXPosAttribute = (xPosAttribute == .trailing) ? NSLayoutConstraint.Attribute.leading : NSLayoutConstraint.Attribute.trailing
//                var pvvXOffset: CGFloat = (pin.side == .left) ? 4 : -4 // distance between value and pin
//
//                chipView.addConstraint(NSLayoutConstraint(item: pinValueView, attribute: pinValueViewXPosAttribute, relatedBy: .equal, toItem: pinView, attribute: invPinValueViewXPosAttribute, multiplier: 1.0, constant: pvvXOffset)) //pvvXOffset
//                chipView.addConstraint(NSLayoutConstraint(item: pinValueView, attribute: .centerY, relatedBy: .equal, toItem: pinView, attribute: .centerY, multiplier: 1.0, constant: 0)) // Y offset of value-pin
//                pinValueView.addConstraint(NSLayoutConstraint(item: pinValueView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: pinValueView.bounds.size.width))
//                pinValueView.addConstraint(NSLayoutConstraint(item: pinValueView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: pinValueView.bounds.size.height))
//
//                pinView.valueView = pinValueView
//        }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.functionView.delegate = self
//
//        self.view.setNeedsDisplay()
//        self.view.layoutIfNeeded()
//
//        self.originalPinFunctionFrame = self.functionView.frame
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        SEGAnalytics.shared().track("Tinker_TinkerScreenActivity")
//    }
//
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        self.showTutorial()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        SEGAnalytics.shared().track("Tinker_TinkerScreenActivity")
//    }


//    override func showTutorial() {
//        if ParticleUtils.shouldDisplayTutorialForViewController(self) {
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
//
//                if self.navigationController?.visibleViewController == self {
//                    // 2
//                    var tutorial = YCTutorialBox(headline: "Blink the onboard LED", withHelpText: "Tap any pin to get started. Start with pin D7 - select 'digitalWrite' and tap the pin, see what happens on your device. You've just flashed an LED over the internet! Reset any pin function by long-pressing it.")
//                    tutorial!.showAndFocus(self.pinViews["D7"])
//
//                    // 1
//                    tutorial = YCTutorialBox(headline: "Welcome to Tinker!", withHelpText: "Tinker is the fastest and easiest way to prototype and play with your Particle device. Access the basic input/output functions of the device pins without writing a line of code.")
//                    tutorial!.showAndFocus(self.chipView)
//
//                    ParticleUtils.setTutorialWasDisplayedForViewController(self)
//                }
//            })
//        }
//    }
//
//    // MARK: - Pin Function Delegate
//    func pinFunctionSelected(function: DevicePinFunction) {
//        hideFunctionView()
//
//        let pin: DevicePin = functionView.pin!
//        var pinView: PinView = pinViews[pin.label]!
//
//        if pin.selectedFunction != function {
//            pin.value = 0
//        }
//        pinView.pin.selectedFunction = function
//
//
//        if function == .none {
//            pinView.active = false
//        } else {
//            pinView.active = true
//            switch function {
//                case .analogWriteDAC, .analogWrite:
//                    pinViewShowingSlider = pinView
////                    pinView.valueView?.delegate = self
////                    pinView.valueView?.showSlider()
//                case .digitalWrite:
//                    pin.value = 0
//                case .digitalRead, .analogRead:
//                    pinCallHome(pinView: pinView)
//                default:
//                    break
//            }
//        }
//    }
//
//    // MARK: - Pin View Delegate
//    func pinViewLongTapped(pinView: PinView) {
////        if let valueView = pinView.valueView, valueView.sliderShowing {
////            pinViewShowingSlider = nil
////        }
//
////        pinView.valueView?.hideSlider()
//        pinView.pin.selectedFunction = .none
//        pinView.active = false
//    }
//
//    func pinViewTapped(pinView: PinView) {
//
//        // if a slider is showing remove it
//        if let pinViewShowingSlider = pinViewShowingSlider, pinViewShowingSlider != pinView {
////            pinViewShowingSlider.valueView?.hideSlider()
//            self.pinViewShowingSlider = nil
//        }
//
//        // if function view is showing, remove it
//        if !functionView.isHidden{
//            hideFunctionView()
//
//            // and show a new one for the new pin (if it's not active yet)
//            if (functionView.pinView != pinView) && (!pinView.active) {
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
//                    self.showFunctionView(pinView)
//                })
//            }
//
//        } else {  // else if pin is not active then show function view
//            if pinView.active == false {
//                self.showFunctionView(pinView)
//            } else {
//                switch pinView.pin.selectedFunction {
//                    case .digitalRead, .analogRead:
//                        pinCallHome(pinView: pinView)
//                    case .digitalWrite:
//                        if pinView.pin.value != nil {
//                            pinView.pin.value = 0
//                        } else {
//                            pinView.pin.value = 1
//                        }
//
//                        pinCallHome(pinView: pinView)
//                    case .analogWriteDAC, .analogWrite:
//                        break
////                        pinView.valueView?.showSlider()
//
////                        chipView.bringSubview(toFront:pinView.valueView!)
////                        pinViewShowingSlider = pinView
////                        pinView.valueView?.delegate = self
//                    default:
//                        break
//                }
//            }
//        }
//    }
//
//    func pinValueViewSliderMoved(_ sender: PinValueView, newValue: Float, touchUp: Bool) {
//        sender.pin.value = Int(newValue)
//
//        var pinView = pinViews[sender.pin.label]!
//        pinView.refresh()
//
//        if touchUp {
//            pinCallHome(pinView: pinView)
//        }
//    }
//
//    // MARK: - Private Methods
//    func showFunctionView(_ pinView: PinView) {
//        if functionView.isHidden {
//            functionView.pin = pinView.pin
//            functionView.pinView = pinView
//
//            functionView.isHidden = false
//
//            var pinFrame: CGRect = pinView.frame
//            pinFrame.size.height = 16
//            pinFrame.size.width = 16
//
//            functionView.frame = pinView.frame
//            functionView.center = CGPoint(x: pinView.center.x, y: pinView.center.y)
//
//            chipView.bringSubview(toFront:functionView)
//            functionView.alpha = 0
//
//            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
//                self.functionView.frame = self.originalPinFunctionFrame!
//
//                self.functionView.alpha = 1
//
//                for (_, pinView) in self.pinViews {
//                    if pinView != pinView {
//                        pinView.alpha = 0.15
//                        pinView.valueView?.alpha = 0.15
//                    }
//                }
//            }, completion: { finished in
//                self.chipView.bringSubview(toFront: self.functionView)
//            })
//        }
//    }
//
//    @IBAction func pinFunctionCancelButtonTapped(_ sender: Any) {
//        hideFunctionView()
//    }
//
//    func hideFunctionView() {
//        let pinView: PinView = functionView.pinView!
//
//        var pinViewFrame = pinView.frame
//        pinViewFrame.size.height = 16
//        pinViewFrame.size.width = 16
//
//        if !functionView.isHidden {
//
//            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
//                self.functionView.alpha = 0.2
//                for (_, pinView) in self.pinViews {
//                    pinView.alpha = 1
//                    //pinView.valueView?.alpha = 1
//                }
//                self.functionView.frame = pinViewFrame
//                self.functionView.center = CGPoint(x: pinView.center.x, y: pinView.center.y)
//            }, completion: { finished in
//                self.functionView.isHidden = true
//                //self.chipView.bringSubview(toFront: pinView.valueView!)
//            })
//        }
//    }
//
//    func pinCallHome(pinView: PinView) {
//        pinView.beginUpdating()
//
//        device.updatePin(pin: pinView.pin.logicalName, function: pinView.pin.selectedFunction, value: pinView.pin.value, success: { result in
//            ///
//            DispatchQueue.main.async(execute: {
//                pinView.endUpdating()
//
//                if pinView.pin.selectedFunction == .digitalWrite || pinView.pin.selectedFunction == .analogWrite || pinView.pin.selectedFunction == .analogWriteDAC {
//                    if result < 0 {
//                        SEGAnalytics.shared().track("Tinker_Error", properties: [
//                            "type": "pin write"
//                        ])
//
//                        RMessage.showNotification(withTitle: "Device pin error", subtitle: "There was a problem writing to this pin.", type: .error, customTypeName: nil, callback: nil)
//                        pinView.pin.value = 0
//                        pinView.active = false
//                    }
//                } else {
//                    pinView.pin.value = result
//                    pinView.refresh()
//                }
//
//                pinView.refresh()
//            })
//        }, failure: { errorMessage in
//            DispatchQueue.main.async(execute: {
//                pinView.endUpdating()
//
//                let errorStr = "Error communicating with device (\(errorMessage ?? ""))"
//                SEGAnalytics.shared().track("Tinker_Error", properties: [
//                    "type": "communicate with device"
//                ])
//
//                RMessage.showNotification(withTitle: "Device error", subtitle: errorStr, type: .error, customTypeName: nil, callback: nil)
//
//                pinView.pin.value = 0
//                pinView.refresh()
//            })
//        })
//    }
//
//
//
//    func resetAllPinFunctions() {
//        for (_, pinView) in pinViews {
//            pinView.pin.selectedFunction = .none
//            pinView.pin.value = 0
//            pinView.active = false
//            //pinView.valueView?.active = false
//
//            pinView.refresh()
//            //pinView.valueView?.refresh()
//        }
//
//    }



