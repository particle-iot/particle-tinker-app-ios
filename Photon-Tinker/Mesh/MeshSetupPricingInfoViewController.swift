//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit

class MeshSetupPricingInfoViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!

    @IBOutlet weak var planTitleLabel: MeshLabel!
    @IBOutlet weak var planTextLabel: MeshLabel!
    
    @IBOutlet weak var priceFreeLabel: MeshLabel!
    @IBOutlet weak var priceLabel: MeshLabel!
    @IBOutlet weak var priceNoteLabel: MeshLabel!
    @IBOutlet weak var priceStrikethroughView: UIView!
    
    @IBOutlet weak var planFeaturesTitleLabel: MeshLabel!
    @IBOutlet weak var planTitleLine1: UIView!
    @IBOutlet weak var planTitleLine2: UIView!
    
    @IBOutlet weak var planFeatureStackView: UIStackView!
    @IBOutlet var planFeatureLables: [MeshLabel]!
    
    @IBOutlet weak var continueButton: MeshSetupButton!

    private var pricingInfo: ParticlePricingInfo!
    private var callback: (() -> ())!

    func setup(didPressContinue: @escaping () -> (), pricingInfo: ParticlePricingInfo) {
        self.callback = didPressContinue
        self.pricingInfo = pricingInfo
    }

    override func setStyle() {
        if (MeshScreenUtils.getPhoneScreenSizeClass() <= .iPhone5) {
            planFeatureStackView.spacing = 10

            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            planTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.BillingTextColor)
            planTextLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.BillingTextColor)

            priceFreeLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)

            priceLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.PriceSize - 10, color: MeshSetupStyle.PrimaryTextColor)
            priceNoteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.BillingTextColor)

            priceStrikethroughView.backgroundColor = MeshSetupStyle.StrikeThroughColor

            planFeaturesTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.SecondaryTextColor)
            planTitleLine1.backgroundColor = MeshSetupStyle.SecondaryTextColor
            planTitleLine2.backgroundColor = MeshSetupStyle.SecondaryTextColor

            for label in planFeatureLables {
                label.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.PrimaryTextColor)
            }

            continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)

        } else {
            planFeatureStackView.spacing = 15

            titleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            planTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.BillingTextColor)
            planTextLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.SmallSize, color: MeshSetupStyle.BillingTextColor)

            priceFreeLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)

            priceLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.PriceSize, color: MeshSetupStyle.PrimaryTextColor)
            priceNoteLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.BillingTextColor)

            priceStrikethroughView.backgroundColor = MeshSetupStyle.StrikeThroughColor

            planFeaturesTitleLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.DetailSize, color: MeshSetupStyle.SecondaryTextColor)
            planTitleLine1.backgroundColor = MeshSetupStyle.SecondaryTextColor
            planTitleLine2.backgroundColor = MeshSetupStyle.SecondaryTextColor

            for label in planFeatureLables {
                label.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
            }

            continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
        }
    }

    override func setContent() {

        self.priceFreeLabel.isHidden = false
        self.priceStrikethroughView.isHidden = false

        for label in planFeatureLables {
            label.text = ""
        }

        switch self.pricingInfo.planSlug ?? "" {
            case "DeviceCloudCellularSelfServe": //add-device-to_user + cellular
                titleLabel.text = MeshSetupStrings.PricingInfo.PaidGatewayDeviceTitle
                planTitleLabel.text = MeshSetupStrings.PricingInfo.DeviceCloudPlanTitle
                planTextLabel.text = MeshSetupStrings.PricingInfo.CellularDeviceText

                priceFreeLabel.text = MeshSetupStrings.PricingInfo.FreeMonthsText.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.freeMonths)")
                planFeaturesTitleLabel.text = MeshSetupStrings.PricingInfo.DeviceCloudFeatures

                planFeatureLables[0].text = MeshSetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = MeshSetupStrings.PricingInfo.FeaturesDataAllowence.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedDataMb)").replacingOccurrences(of: "{{1}}", with: formatCurrency(pricingInfo.plan.overageMinCostMb!))
                planFeatureLables[2].text = MeshSetupStrings.PricingInfo.FeaturesStandardSupport
            case "MeshMicroCellular": //create-network + cellular
                titleLabel.text = MeshSetupStrings.PricingInfo.PaidNetworkTitle
                planTitleLabel.text = MeshSetupStrings.PricingInfo.MicroNetworkPlanTitle
                planTextLabel.text = MeshSetupStrings.PricingInfo.CellularGatewayText

                priceFreeLabel.text = MeshSetupStrings.PricingInfo.FreeMonthsText.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.freeMonths)")
                planFeaturesTitleLabel.text = MeshSetupStrings.PricingInfo.MeshNetworkFeatures

                planFeatureLables[0].text = MeshSetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = MeshSetupStrings.PricingInfo.FeaturesMaxDevices.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedNodeCount)")
                planFeatureLables[2].text = MeshSetupStrings.PricingInfo.FeaturesMaxGateways.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedGatewayCount)")
                planFeatureLables[3].text = MeshSetupStrings.PricingInfo.FeaturesDataAllowence.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedDataMb)").replacingOccurrences(of: "{{1}}", with: formatCurrency(pricingInfo.plan.overageMinCostMb!))
                planFeatureLables[4].text = MeshSetupStrings.PricingInfo.FeaturesStandardSupport

            case "MeshMicroWifi": //create-network + wifi
                titleLabel.text = MeshSetupStrings.PricingInfo.FreeNetworkTitle
                planTitleLabel.text = MeshSetupStrings.PricingInfo.MicroNetworkPlanTitle
                planTextLabel.text = MeshSetupStrings.PricingInfo.WifiGatewayText

                priceFreeLabel.text = MeshSetupStrings.PricingInfo.FreeNetworksText.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.freeWifiNetworkMaxCount)")
                planFeaturesTitleLabel.text = MeshSetupStrings.PricingInfo.MeshNetworkFeatures

                planFeatureLables[0].text = MeshSetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = MeshSetupStrings.PricingInfo.FeaturesMaxDevices.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedNodeCount)")
                planFeatureLables[2].text = MeshSetupStrings.PricingInfo.FeaturesMaxGateways.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.includedGatewayCount)")
                planFeatureLables[3].text = MeshSetupStrings.PricingInfo.FeaturesStandardSupport

            default: //add-device-to-user + wifi
                titleLabel.text = MeshSetupStrings.PricingInfo.FreeGatewayDeviceTitle
                planTitleLabel.text = MeshSetupStrings.PricingInfo.DeviceCloudPlanTitle
                planTextLabel.text = MeshSetupStrings.PricingInfo.WifiDeviceText

                priceFreeLabel.text = MeshSetupStrings.PricingInfo.FreeDevicesText.replacingOccurrences(of: "{{0}}", with: "\(pricingInfo.plan.freeDeviceMaxCount)")
                planFeaturesTitleLabel.text = MeshSetupStrings.PricingInfo.DeviceCloudFeatures

                planFeatureLables[0].text = MeshSetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = MeshSetupStrings.PricingInfo.FeaturesStandardSupport
        }

        priceLabel.text = MeshSetupStrings.PricingInfo.PriceText.replacingOccurrences(of: "{{0}}", with: formatCurrency(pricingInfo.plan.monthlyBaseAmount!))
        priceNoteLabel.text = MeshSetupStrings.PricingInfo.PriceNoteText

        for label in planFeatureLables {
            label.isHidden = (label.text!.count == 0)
        }

        if self.pricingInfo.chargeable {
            self.continueButton.setTitle(MeshSetupStrings.PricingInfo.ButtonEnroll, for: .normal)
        } else {
            self.continueButton.setTitle(MeshSetupStrings.PricingInfo.ButtonNext, for: .normal)
        }
    }

    private func formatCurrency(_ decimal: NSDecimalNumber) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.groupingSeparator = ","

        currencyFormatter.decimalSeparator = "."
        currencyFormatter.minimumIntegerDigits = 1

        currencyFormatter.usesSignificantDigits = false
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2

        return currencyFormatter.string(from: decimal)!
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

        viewsToFade!.append(planTitleLabel)
        viewsToFade!.append(planTextLabel)

        viewsToFade!.append(priceFreeLabel)
        viewsToFade!.append(priceLabel)
        viewsToFade!.append(priceNoteLabel)
        viewsToFade!.append(priceStrikethroughView)

        viewsToFade!.append(planTitleLabel)
        viewsToFade!.append(planTitleLine1)
        viewsToFade!.append(planTitleLine2)
        viewsToFade!.append(planFeatureStackView)

        viewsToFade!.append(continueButton)
    }





    @IBAction func continueButtonTapped(_ sender: Any) {
        self.fade()

        callback()
    }
}
