//
//  DataEntrySetupValue.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 14/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import Foundation
import UIKit

class DataEntryFormSetupAmount: DataEntryFormSetup {
	var topLabel = UILabel()
	
	var backgroundView = UIView()
	
	var isGiving = true
	var currentAmount: Float = 0.0
	var displayAmount = Array<Int>()
	
	class var currencyIndicator: String {
		//TODO: MAKE THIS GET THE CURRENCY FROM SOMEWHERE
		return "£"
	}
	
	class var thousandsSeparator: String {
		return ","
	}
	
	class var decimalSeparator: String {
		return "."
	}
	
	
	//MARK: - Initialisation
	convenience init(title: String?, delegate: DataEntryFormSetupDelegate) {
		self.init(title: title, type: .Amount, delegate: delegate)
	}
	
	required init(title: String?, type: DataEntryFormSetupType, delegate: DataEntryFormSetupDelegate) {
		super.init(title: title, type: type, delegate: delegate)
		
		println(self.formTitle)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Main Drawing
	override func drawView() {
		var viewsToAdd = Array<UIView>()
		
		//MARK: create the top bit
		backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
		backgroundView.backgroundColor = .redColor()
		
		//MARK: add label to the top bit
		topLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		if UIFont.respondsToSelector("systemFontOfSize:weight:") {
			topLabel.font = UIFont.systemFontOfSize(50.0, weight: UIFontWeightThin)
		} else {
			topLabel.font = UIFont.systemFontOfSize(50.0)
		}
		topLabel.adjustsFontSizeToFitWidth = true
		topLabel.minimumScaleFactor = 0.5
		
		topLabel.textColor = .whiteColor()
		topLabel.textAlignment = .Right
		
		backgroundView.addSubview(topLabel)
		
		
		//MARK: add a give/get button
		let giveGetButton = self.giveGetButton()
		backgroundView.addSubview(giveGetButton)
		
		//MARK: Create a spacer
		let spacer = UIView()
		spacer.backgroundColor = .clearColor()
		self.view.addSubview(spacer)
		spacer.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		//MARK: Constraints
		//put first view into array
		viewsToAdd += [backgroundView]
		
		//begin creating the definitions
		var viewsDict: Dictionary<String, UIView> = ["backgroundView": backgroundView, "topLabel" : topLabel, "giveGetButton" : giveGetButton, "_Spacer" : spacer]
		let metrics = ["exteriorSpacing" : 10.0, "interiorSpacing" : 2.0]
		
		
		//create buttons and add them into the relevant arrays/dictionaries
		let buttons: Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Delete"]
		
		var counter = 0
		
		for buttonToMake in buttons {
			let butt = self.createButtonWithTitleAndTag(buttonToMake, buttonTag: counter)
			viewsDict["_" + buttonToMake] = butt
			viewsToAdd += [butt]
			
			println("Creating button: (\(buttonToMake)")
			
			switch butt.tag {
			case 10: butt.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
				break
			default: butt.addTarget(self, action: "numberButtonPressed:", forControlEvents: .TouchUpInside)
			}
			
			counter++
		}
		
		//add all views to the main view
		for viewToAdd in viewsToAdd {
			self.view.addSubview(viewToAdd)
		}
		
		//now create all these bloody constraints
		var constraints = Array<AnyObject>()
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundView]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView(80)][_7]", options: nil, metrics: nil, views: viewsDict)
		
		var constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("|-exteriorSpacing-[giveGetButton(40)]->=interiorSpacing-[topLabel]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		constraints2 += NSLayoutConstraint.constraintsWithVisualFormat("V:|-exteriorSpacing-[topLabel]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		constraints2 += NSLayoutConstraint.constraintsWithVisualFormat("V:|-exteriorSpacing-[giveGetButton]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		
		//Horizontal constraints
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[_7][_8(_7)][_9(_8)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[_4][_5(_4)][_6(_5)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[_1][_2(_1)][_3(_2)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("|[_Spacer][_0(_Spacer)][_Delete(_0)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		
		
		//Vertical Constraints
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_7][_4(_7)][_1(_4)][_Spacer(_1)]|", options: .AlignAllCenterX, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_8][_5(_8)][_2(_5)][_0(_2)]|", options: .AlignAllCenterX, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_9][_6(_9)][_3(_6)][_Delete(_3)]|", options: .AlignAllCenterX, metrics: nil, views: viewsDict)
		
		self.view.addConstraints(constraints)
		backgroundView.addConstraints(constraints2)
	}
	
	func createButtonWithTitleAndTag(title: String, buttonTag: Int) -> UIButton {
		let butt = UIButton.buttonWithType(.System) as! UIButton
		
		butt.setTitle(title, forState: UIControlState.Normal)
		butt.tag = buttonTag
		
		butt.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		butt.setTitleColor(UIColor.redColor(), forState: .Normal)
		
		if buttonTag == 10{
			butt.setTitle("<=", forState: .Normal)
		}
		
		butt.titleLabel!.font = UIFont.systemFontOfSize(40.0, weight: UIFontWeightThin)
		
		return butt
	}
	
	func giveGetButton() -> UIButton {
		var butt = UIButton.buttonWithType(.System) as! UIButton
		butt.setTitle("Give", forState: .Normal)
		butt.tag = 0
		butt.addTarget(self, action: "getGiveButtonPressed:", forControlEvents: .TouchUpInside)
		butt.setTranslatesAutoresizingMaskIntoConstraints(false)
		return butt
	}
	
	
	//MARK: - Delegate Methods
	override func doneButtonPressed(sender: AnyObject) {
		println("Done button pressed")
		
		if self.isGiving {
			self.delegate?.dataEntryFormSetupAmountDidFinish!(self.currentAmount, setup: self)
		} else {
			self.delegate?.dataEntryFormSetupAmountDidFinish!(self.currentAmount * -1, setup: self)
		}
	}
	
	override func cancelButtonPressed(sender: AnyObject) {
		super.delegate?.dataEntryFormSetupDidCancel(self)
	}
	
	func numberButtonPressed(sender: AnyObject) {
		//prevent zero from being added in at the start
		if self.displayAmount.count == 0 && sender.tag == 0 {
			//do nothing
		} else if displayAmount.count <= 10 {
			self.displayAmount += [sender.tag]
		} else {
			//TODO: ADD METHOD FOR DISPLAYING MESSAGE
		}
		
		//set up the new display string
		self.updateDisplayValue()
	}
	
	func deleteButtonPressed(sender: AnyObject) {
		if self.displayAmount.count > 0 {
			self.displayAmount.removeLast()
			self.updateDisplayValue()
		}
	}
	
	func getGiveButtonPressed(sender: UIButton) {
		println("Got to getgot button pressed")
		if sender.tag == 0 {
			sender.tag = 1
			sender.setTitle("Get", forState: .Normal)
			self.isGiving = false
		} else {
			sender.tag = 0
			sender.setTitle("Give", forState: .Normal)
			self.isGiving = true
		}
	}
	
	
	//MARK:- Respond to input
	func updateDisplayValue() {
		if self.displayAmount.count > 0 {
			var displayString = DataEntryFormSetupAmount.currencyIndicator
			var counter = 0
			
			if self.displayAmount.count < 3 {
				if self.displayAmount.count == 2 {
					displayString += "0"
				} else if self.displayAmount.count == 1 {
					displayString += "0\(DataEntryFormSetupAmount.decimalSeparator)0"
				}
			}
			
			for value in self.displayAmount {
				//add decimal point if this is to be the penultimate number
				if self.displayAmount.count - counter == 2 {
					displayString += DataEntryFormSetupAmount.decimalSeparator
				}
				
				//add a thousands separator if necessary
				if self.displayAmount.count - counter == 5 && self.displayAmount.count > 5 {
					displayString += DataEntryFormSetupAmount.thousandsSeparator
				}
				
				if self.displayAmount.count - counter == 8 && self.displayAmount.count > 8 {
					displayString += DataEntryFormSetupAmount.thousandsSeparator
				}
				
				displayString += "\(value)"
				
				counter++
			}
			
			self.topLabel.text = displayString
			
			let stringMinusCurrency = displayString.stringByReplacingOccurrencesOfString(DataEntryFormSetupAmount.currencyIndicator, withString: "", options: .CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(DataEntryFormSetupAmount.decimalSeparator, withString: ".", options: .CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(DataEntryFormSetupAmount.thousandsSeparator, withString: "", options: .CaseInsensitiveSearch, range: nil)
			
			if let newAmountValue = stringMinusCurrency.floatValue {
				if self.isGiving {
					self.currentAmount = newAmountValue
				} else {
					self.currentAmount = newAmountValue * -1.0
				}
			} else {
				self.currentAmount = 0.0
			}
			
		} else {
			self.topLabel.text = "\(NSNumberFormatter().currencySymbol)0\(DataEntryFormSetupAmount.decimalSeparator)00"
		}
	}
	
}





