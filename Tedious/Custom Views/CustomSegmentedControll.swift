//
//  CustomSegmentedControll.swift
//  CustomSegControll
//
//  Created by Pavle Mijatovic on 12/13/17.
//  Copyright © 2017 Pavle Mijatovic. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {

    //MARK: - Properties
    //Constants
    //Vars
    private var buttons = [UIButton]()
    private var selector: UIView!
    var selectedSegmentIndex = 0 // Starting index
    //Inspectable vars
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var commaSeperatedBtnTitles: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var txtColor: UIColor = .lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = .darkGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectorTxtColor: UIColor = .white {
        didSet {
            updateView()
        }
    }
    
    //MARK: - Helper
    private func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = commaSeperatedBtnTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(txtColor, for: .normal)
            button.titleLabel?.font = UIFont(name: K.Font.Regular, size: 20)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectorTxtColor, for: .normal)
        
        let selectorWitdh = frame.width / CGFloat(buttonTitles.count)
        
        selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWitdh, height: frame.height))
        selector.layer.cornerRadius = frame.height / 2
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func selectButton(atIndex index: Int) {
        buttonTapped(button: buttons[index])
    }
    
    //MARK: - Actions
    @objc func buttonTapped(button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(txtColor, for: .normal)
            
            if btn == button {
                selectedSegmentIndex = buttonIndex
                let selectorStartPosition = frame.width/CGFloat(buttons.count) * CGFloat(buttonIndex)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition
                })
                btn.setTitleColor(selectorTxtColor, for: .normal)
            }
        }
        
        sendActions(for: .valueChanged)
    }
    
    //MARK: - Lifecycle
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height / 2
        updateView()
    }
}
