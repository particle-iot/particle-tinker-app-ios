//
// Created by Raimundas Sakalauskas on 2019-05-10.
// Copyright (c) 2019 Particle. All rights reserved.
//

import Foundation

class PieProgressView: UIView {

    static var defaultPieColor: UIColor = UIColor(red: 0.612, green: 0.710, blue: 0.839, alpha: 1.0)
    static let kAngleOffset: CGFloat = -90.0

    var progress: CGFloat = 0.0 {
        didSet {
            progress = max(0, min(1.0, progress))
            self.setNeedsDisplay()
        }
    }

    var pieBorderWidth: CGFloat = 2.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var pieInnerBorderWidth: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var pieBorderColor: UIColor = PieProgressView.defaultPieColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var pieInnerBorderColor: UIColor = PieProgressView.defaultPieColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var pieFillColor: UIColor = PieProgressView.defaultPieColor {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var pieBackgroundColor: UIColor = .clear {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("unable to obtain drawable context")
        }

        // Background
        pieBackgroundColor.set()
        context.fillEllipse(in: rect)

        // Math
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = center.y
        let angle = ((.pi * (360.0 * progress) + PieProgressView.kAngleOffset) / 180)
        let points = [CGPoint(x: center.x, y: 0.0), center, CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))]

        // Fill
        pieFillColor.set()
        if progress > 0.0 {
            context.addLines(between: points)
            context.addArc(center: CGPoint(x: center.x, y: center.y), radius: radius, startAngle: ((.pi * PieProgressView.kAngleOffset) / 180), endAngle: angle, clockwise: false)
            context.drawPath(using: .eoFill)
        }

        // Inner Border
        if progress < 0.99 && pieInnerBorderWidth > 0.0 {
            pieInnerBorderColor.set()
            context.addLines(between: points)
            context.drawPath(using: .stroke)
        }

        // Outer Border
        if pieBorderWidth > 0.0 {
            pieBorderColor.set()
            context.setLineWidth(pieBorderWidth)
            let pieInnerRect = CGRect(x: pieBorderWidth / 2.0, y: pieBorderWidth / 2.0, width: rect.size.width - pieBorderWidth, height: rect.size.height - pieBorderWidth)
            context.strokeEllipse(in: pieInnerRect)
        }
    }

}