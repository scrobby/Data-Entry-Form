//
//  DataEntryFormController.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 19/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import Foundation
import UIKit

struct FormToDisplayWithAnimations {
	var form: DataEntryForm
	var animations: FormAnimations
}

struct FormTypeWithTitle {
	var formType: DataEntryFormType
	var title: String
}

struct FormAnimations {
	var showAnimation: DataEntryFormAnimationType
	var dismissAnimation: DataEntryFormAnimationType
}

class DataEntryFormController: NSObject, DataEntryFormDelegate {
	var formsToDisplay = Array<FormToDisplayWithAnimations>()
	var currentFormNumber = -1
	
	
	//requires a form that has already been configured
	init(forms: Array<FormToDisplayWithAnimations>) {
		super.init()
		
		var counter = 0
		
		for formToAdd in forms {
			let form = formToAdd.form
			let animations = self.selectAnimations(counter, totalForms: forms.count, showAnimation: formToAdd.animations.showAnimation, dismissAnimation: formToAdd.animations.dismissAnimation)
			
			if (counter + 1) == forms.count {
				form.shouldBounce = true
			} else {
				form.shouldBounce = false
			}
			
			self.formsToDisplay += [FormToDisplayWithAnimations(form: form, animations: animations)]
		}
	}
	
	init(formTypesWithTitles: Array<FormTypeWithTitle>, andAnimations: FormAnimations) {
		super.init()
		
		var counter = 0
		
		for formToAdd in formTypesWithTitles {
			let newForm = self.createFormWithType(formToAdd.formType, title: formToAdd.title, delegate: self)
			let animations = self.selectAnimations(counter, totalForms: formTypesWithTitles.count, showAnimation: andAnimations.showAnimation, dismissAnimation: andAnimations.dismissAnimation)
			
			if (counter + 1) == formTypesWithTitles.count {
				newForm.shouldBounce = true
			} else {
				newForm.shouldBounce = false
			}
			
			self.formsToDisplay += [FormToDisplayWithAnimations(form: newForm, animations: animations)]
			
			counter++
		}
	}
	
	//MARK: - Showing
	func show() {
		self.showNextForm()
	}
	
	//MARK: - Work out what the animations should be
	func selectAnimations(currentAddition: Int, totalForms: Int, showAnimation: DataEntryFormAnimationType?, dismissAnimation: DataEntryFormAnimationType?) -> FormAnimations {
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
		
		if shouldCalculateShowAnimation {
			if currentAddition == 0 {
				newShowAnimation = .Top
			} else {
				newShowAnimation = .Right
			}
		}
		
		if shouldCalculateDismissAnimation {
			if (currentAddition + 1) == totalForms {
				newDismissAnimation = .Top
			} else {
				newDismissAnimation = .Left
			}
		}
		
		return FormAnimations(showAnimation: newShowAnimation, dismissAnimation: newDismissAnimation)
	}
	
	//MARK: - Work out which form to show
	func showNextForm() {
		currentFormNumber++
		
		if currentFormNumber < self.formsToDisplay.count {
			let formToShow = self.formsToDisplay[currentFormNumber]
			formToShow.form.show(formToShow.animations.showAnimation)
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
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormAmountDidFinish(amount: Float, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormTextDidFinish(text: String, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormDateDidFinish(date: NSDate, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		self.showNextForm()
	}
	
	func DataEntryFormCustomDidFinish(payload: Dictionary<String, AnyObject>, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		self.showNextForm()
	}
}