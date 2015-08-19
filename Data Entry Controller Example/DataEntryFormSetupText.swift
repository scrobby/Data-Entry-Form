//
//  DataEntryFormSetupText.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 18/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import Foundation
import UIKit

class DataEntryFormSetupText: DataEntryFormSetup {
	let viewHeight: CGFloat = 70.0
	var textBox = UITextField()
	
	//MARK: - Initialisers
	convenience init(title: String, delegate: DataEntryFormSetupDelegate, placeholder: String) {
		self.init(title: title, type: .Text, delegate: delegate)
		
		self.textBox.placeholder = placeholder
		self.textBox.font = UIFont.systemFontOfSize(40, weight: UIFontWeightThin)
		self.textBox.adjustsFontSizeToFitWidth = true
		self.textBox.textAlignment = .Center
		
		self.contentView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
	}
	
	required init(title: String?, type: DataEntryFormSetupType, delegate: DataEntryFormSetupDelegate) {
		super.init(title: title, type: type, delegate: delegate)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.formType = .Text
	}
	
	//MARK: - Drawing
	override func drawView() {
		self.textBox.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.contentView.addSubview(textBox)
		
		var constraints = Array<AnyObject>()
		var viewsDict: Dictionary<String, UIView> = ["textBox" : self.textBox]
		let metrics: Dictionary<String, CGFloat> = ["exteriorSpacing" : 2.0]
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-exteriorSpacing-[textBox]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[textBox]|", options: nil, metrics: nil, views: viewsDict)
		
		self.contentView.addConstraints(constraints)
	}
	
	//MARK: - Showing/Disappearing
	override func didShow() {
		self.textBox.becomeFirstResponder()
	}
	
	override func willDisappear() {
		self.textBox.resignFirstResponder()
	}
	
	//MARK: - Overrides
	override func preferredViewHeight() -> CGFloat {
		return viewHeight
	}
}
