//
//  DataEntryFormController.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 19/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import Foundation
import UIKit

class DataEntryFormController: NSObject, DataEntryFormDelegate {
	var formsToDisplay = Array<(form: DataEntryForm, showAnimation: DataEntryFormAnimationType, dismissAnimation: DataEntryFormAnimationType)>()
	var currentFormNumber = -1
	
	init(formTypesWithTitles: Array<(type: DataEntryFormType, title: String?)>, showAnimation: DataEntryFormAnimationType?, dismissAnimation: DataEntryFormAnimationType?) {
		super.init()
		
		var newShowAnimation = DataEntryFormAnimationType.Top
		var newDismissAnimation = DataEntryFormAnimationType.Bottom
		
		var shouldCalculateShowAnimation = true
		var shouldCalculateDismissAnimation = true
		
		if showAnimation != nil {
			newShowAnimation = showAnimation!
			shouldCalculateShowAnimation = false
		}
		
		if dismissAnimation != nil {
			newDismissAnimation = dismissAnimation!
			shouldCalculateDismissAnimation = false
		}
		
		var counter = 0
		
		for formToAdd in formTypesWithTitles {
			let newForm = self.createFormWithType(formToAdd.type, title: formToAdd.title, delegate: self)
			
			if shouldCalculateShowAnimation {
				if counter == 0 {
					newShowAnimation = .Top
				} else {
					newShowAnimation = .Right
				}
			}
			
			if shouldCalculateDismissAnimation {
				if (counter + 1) == formTypesWithTitles.count {
					newDismissAnimation = .Top
					newForm.shouldBounce = true
				} else {
					newDismissAnimation = .Left
					newForm.shouldBounce = false
				}
			}
			
			if (counter + 1) == formTypesWithTitles.count {
				newForm.shouldBounce = true
			} else {
				newForm.shouldBounce = false
			}
			
			self.formsToDisplay += [(form: newForm, showAnimation: newShowAnimation, dismissAnimation: newDismissAnimation)]
			
			counter++
		}
	}
	
	//MARK: - Showing
	func show() {
		self.showNextForm()
	}
	
	//MARK: - Work out which form to show
	func showNextForm() {
		currentFormNumber++
		
		if currentFormNumber < self.formsToDisplay.count {
			let formToShow = self.formsToDisplay[currentFormNumber]
			formToShow.form.show(formToShow.showAnimation)
		} else {
			//REACHED THE END
		}
	}
	
	//MARK: - Create forms from types
	func createFormWithType(type: DataEntryFormType, title: String?, delegate: DataEntryFormDelegate) -> DataEntryForm {
		switch type {
		case .Amount:
			return DataEntryFormAmount(title: title, delegate: delegate)
		case .Text:
			return DataEntryFormText(title: "", delegate: delegate, placeholder: "")
		case .Date:
			return DataEntryFormDate(title: title, delegate: delegate, dates: nil)
		default:
			return DataEntryForm(title: title, type: type, delegate: delegate)
		}
	}
	
	//MARK: - DataEntryFormDelegate Methods
	func DataEntryFormDidCancel(setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormAmountDidFinish(amount: Float, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormTextDidFinish(text: String, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormDateDidFinish(date: NSDate, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormCustomDidFinish(payload: Dictionary<String, AnyObject>, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].dismissAnimation)
		self.showNextForm()
	}
}