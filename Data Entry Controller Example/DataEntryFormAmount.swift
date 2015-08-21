//
//  DataEntrySetupValue.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 14/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import Foundation
import UIKit

enum DataEntryFormAmountOption {
	case UseCurrency
}

class DataEntryFormAmount: DataEntryForm {
	var topLabel = UILabel()
	
	var backgroundView = UIView()
	
	var isPositive = true
	var currentAmount: Float = 0.0
	var displayAmount = Array<Int>()
	
	class var currencyIndicator: String {
		if NSNumberFormatter().currencySymbol != nil {
			return NSNumberFormatter().currencySymbol!
		} else {
			return "$"
		}
	}
	
	class var thousandsSeparator: String {
		return ","
	}
	
	class var decimalSeparator: String {
		return "."
	}
	
	//MARK: - Initialisation
	convenience init(title: String?, delegate: DataEntryFormDelegate) {
		self.init(title: title, type: .Amount, delegate: delegate)
	}
	
	required init(title: String?, type: DataEntryFormType, delegate: DataEntryFormDelegate) {
		super.init(title: title, type: type, delegate: delegate)
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Main Drawing
	override func drawView() {
		var viewsToAdd = Array<UIView>()
		
		self.contentView.backgroundColor = .clearColor()
		
		//MARK: create the top bit
		backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
		backgroundView.backgroundColor = .clearColor()
		
		//MARK: add label to the top bit
		topLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		if UIFont.respondsToSelector("systemFontOfSize:weight:") {
			topLabel.font = UIFont.systemFontOfSize(50.0, weight: UIFontWeightThin)
		} else {
			topLabel.font = UIFont.systemFontOfSize(50.0)
		}
		topLabel.adjustsFontSizeToFitWidth = true
		topLabel.minimumScaleFactor = 0.5
		
		topLabel.textColor = .blackColor()
		topLabel.textAlignment = .Right
		
		backgroundView.addSubview(topLabel)
		
		//MARK: Create a spacer
		let divider = UIView()
		divider.backgroundColor = .grayColor()
		self.contentView.addSubview(divider)
		divider.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		//MARK: Constraints
		//put first view into array
		viewsToAdd += [backgroundView]
		
		//begin creating the definitions
		var viewsDict: Dictionary<String, UIView> = ["backgroundView": backgroundView, "topLabel" : topLabel, "divider" : divider]
		let metrics = ["exteriorSpacing" : 10.0, "interiorSpacing" : 2.0]
		
		
		//create buttons and add them into the relevant arrays/dictionaries
		let buttons: Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Delete", "negative"]
		
		var counter = 0
		
		for buttonToMake in buttons {
			let butt = self.createButtonWithTitleAndTag(buttonToMake, buttonTag: counter)
			viewsDict["_" + buttonToMake] = butt
			viewsToAdd += [butt]
			
			switch butt.tag {
			case 10:
				butt.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
				break
			case 11:
				butt.addTarget(self, action: "negativeSwitcherButtonPressed:", forControlEvents: .TouchUpInside)
				break
			default:
				butt.addTarget(self, action: "numberButtonPressed:", forControlEvents: .TouchUpInside)
				break
			}
			
			counter++
		}
		
		//add all views to the main view
		for viewToAdd in viewsToAdd {
			self.contentView.addSubview(viewToAdd)
		}
		
		//now create all these bloody constraints
		var constraints2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-exteriorSpacing-[topLabel]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		constraints2 += NSLayoutConstraint.constraintsWithVisualFormat("V:|-exteriorSpacing-[topLabel]-exteriorSpacing-|", options: nil, metrics: metrics, views: viewsDict)
		
		//Horizontal constraints
		var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView(80)][divider(1)][_7]", options: nil, metrics: nil, views: viewsDict)
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[divider]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[_7][_8(_7)][_9(_8)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[_4][_5(_4)][_6(_5)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[_1][_2(_1)][_3(_2)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[_negative][_0(_negative)][_Delete(_0)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		
		
		//Vertical Constraints
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_7][_4(_7)][_1(_4)][_negative(_1)]-0-|", options: .AlignAllCenterX, metrics: metrics, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_8][_5(_8)][_2(_5)][_0(_2)]-0-|", options: .AlignAllCenterX, metrics: metrics, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[_9][_6(_9)][_3(_6)][_Delete(_3)]-0-|", options: .AlignAllCenterX, metrics: metrics, views: viewsDict)
		
		self.contentView.addConstraints(constraints)
		backgroundView.addConstraints(constraints2)
	}
	
	func createButtonWithTitleAndTag(title: String, buttonTag: Int) -> UIButton {
<<<<<<< HEAD
		let butt = UIButton.buttonWithType(.System) as! UIButton
		
		butt.setTitle(title, forState: UIControlState.Normal)
		butt.tag = buttonTag
		
		butt.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		butt.setTitleColor(self.tintColor, forState: .Normal)
		butt.titleLabel!.font = UIFont.systemFontOfSize(40.0, weight: UIFontWeightThin)
		
		butt.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
=======
		var butt = UIButton.buttonWithType(.System) as! UIButton
>>>>>>> optimise-animations
		
		if buttonTag == 10 || buttonTag == 11 {
			butt.titleLabel?.font = UIFont.systemFontOfSize(25.0, weight: UIFontWeightRegular)
			
			if buttonTag == 10 {
				butt.setTitle("←", forState: .Normal)
			} else if buttonTag == 11 {
				butt.setTitle("+/-", forState: .Normal)
			}
		} else {
			butt.setTitle(title, forState: UIControlState.Normal)
			butt.titleLabel!.font = UIFont.systemFontOfSize(40.0, weight: UIFontWeightThin)
		}
		
		butt.tag = buttonTag
		
		butt.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		butt.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			if buttonTag == 10 || buttonTag == 11 {
				butt.titleLabel?.font = UIFont.systemFontOfSize(25.0, weight: UIFontWeightRegular)
				
				if buttonTag == 10 {
					butt.setTitle("<=", forState: .Normal)
				} else if buttonTag == 11 {
					butt.setTitle("+/-", forState: .Normal)
				}
			}
		})
		
		return butt
	}
	
	//MARK: - Delegate Methods
	override func doneButtonPressed(sender: AnyObject) {
		if self.isPositive {
			self.delegate?.DataEntryFormAmountDidFinish!(self.currentAmount, setup: self)
		} else {
			self.delegate?.DataEntryFormAmountDidFinish!(self.currentAmount * -1, setup: self)
		}
	}
	
	override func cancelButtonPressed(sender: AnyObject) {
		super.delegate?.DataEntryFormDidCancel(self)
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
	
	func negativeSwitcherButtonPressed(sender: UIButton) {
		if sender.tag == 0 {
			sender.tag = 1
			self.isPositive = true
		} else {
			sender.tag = 0
			self.isPositive = false
		}
		
		self.updateDisplayValue()
	}
	
	
	//MARK:- Respond to input
	func updateDisplayValue() {
		if self.displayAmount.count > 0 {
			var displayString = String()
			
			if isPositive {
				displayString = DataEntryFormAmount.currencyIndicator
			} else {
				displayString = "-\(DataEntryFormAmount.currencyIndicator)"
			}
			
			var counter = 0
			
			if self.displayAmount.count < 3 {
				if self.displayAmount.count == 2 {
					displayString += "0"
				} else if self.displayAmount.count == 1 {
					displayString += "0\(DataEntryFormAmount.decimalSeparator)0"
				}
			}
			
			for value in self.displayAmount {
				//add decimal point if this is to be the penultimate number
				if self.displayAmount.count - counter == 2 {
					displayString += DataEntryFormAmount.decimalSeparator
				}
				
				//add a thousands separator if necessary
				if self.displayAmount.count - counter == 5 && self.displayAmount.count > 5 {
					displayString += DataEntryFormAmount.thousandsSeparator
				}
				
				if self.displayAmount.count - counter == 8 && self.displayAmount.count > 8 {
					displayString += DataEntryFormAmount.thousandsSeparator
				}
				
				displayString += "\(value)"
				
				counter++
			}
			
			self.topLabel.text = displayString
			
			let stringMinusCurrency = displayString.stringByReplacingOccurrencesOfString(DataEntryFormAmount.currencyIndicator, withString: "", options: .CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(DataEntryFormAmount.decimalSeparator, withString: ".", options: .CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(DataEntryFormAmount.thousandsSeparator, withString: "", options: .CaseInsensitiveSearch, range: nil)
			
			if let newAmountValue = stringMinusCurrency.floatValue {
				if self.isPositive {
					self.currentAmount = newAmountValue
				} else {
					self.currentAmount = newAmountValue * -1.0
				}
			} else {
				self.currentAmount = 0.0
			}
			
		} else {
			self.topLabel.text = "\(DataEntryFormAmount.currencyIndicator)0\(DataEntryFormAmount.decimalSeparator)00"
		}
	}
	
	//MARK: - Override
	override func willShow() {
		self.updateDisplayValue()
	}
	
	override func preferredViewHeight() -> CGFloat {
		return 350.0
	}
}





