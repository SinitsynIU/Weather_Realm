//
//  ButtonCustom.swift
//  Checkers
//
//  Created by Илья Синицын on 08.02.2022.
//

import UIKit

@IBDesignable
class ButtonCustom: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
        @IBInspectable var cornerRadius: CGFloat {
            set { contentView.layer.cornerRadius = newValue }
            get { contentView.layer.cornerRadius }
        }
        
        @IBInspectable var borderWidth: CGFloat {
            set { contentView.layer.borderWidth = newValue }
            get { contentView.layer.borderWidth }
        }

        @IBInspectable var borderColor: UIColor {
            set { contentView.layer.borderColor = newValue.cgColor }
            get {
                if let borderColor = contentView.layer.borderColor {
                    return UIColor(cgColor: borderColor)
                }
                return UIColor.clear
            }
        }
        
        @IBInspectable var bgColor: UIColor {
            set { contentView.backgroundColor = newValue }
            get { return contentView.backgroundColor ?? .clear }
        }
        
        @IBInspectable var text: String {
            set { textLabel.text = newValue }
            get { return textLabel.text ?? "" }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI()
        }
        
        private func setupUI() {
            Bundle(for: ButtonCustom.self).loadNibNamed("ButtonCustom", owner: self, options: nil)
            contentView.frame = bounds
            addSubview(contentView)
        }
}
