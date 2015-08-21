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

protocol DataEntryFormControllerDelegate: DataEntryFormDelegate {
	func dataEntryFormControllerDidCancel(controller: DataEntryFormController)
	func dataEntryFormControllerDidFinish(controller: DataEntryFormController)
}

class DataEntryFormController: NSObject, DataEntryFormDelegate {
	private var _backgroundImageView: UIImageView?
	private var backgroundImageView: UIImageView {
		if self._backgroundImageView == nil {
			self._backgroundImageView = UIImageView(frame: AppDelegate.keyWindow.bounds)
		}
		
		self._backgroundImageView?.backgroundColor = .blackColor()
		
		return self._backgroundImageView!
	}
	
	var delegate: DataEntryFormControllerDelegate?
	
	var formsToDisplay = Array<FormToDisplayWithAnimations>()
	var currentFormNumber = -1
	
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
	
	init(forms: Array<DataEntryForm>, startAndEndAnimations: FormAnimations, middleAnimations: FormAnimations) {
		super.init()
		
		var counter = 0
		
		for formToAdd in forms {
			var newAnimations: FormAnimations?
			
			if counter == 0 {
				newAnimations = FormAnimations(showAnimation: startAndEndAnimations.showAnimation, dismissAnimation: middleAnimations.dismissAnimation)
			} else if counter + 1 == forms.count {
				newAnimations = FormAnimations(showAnimation: middleAnimations.showAnimation, dismissAnimation: startAndEndAnimations.dismissAnimation)
			} else {
				newAnimations = middleAnimations
			}
			
			self.formsToDisplay += [FormToDisplayWithAnimations(form: formToAdd, animations: newAnimations!)]
			
			counter++
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
	
	init(formTypesWithTitles: Array<FormTypeWithTitle>, startAndEndAnimations: FormAnimations, middleAnimations: FormAnimations) {
		super.init()
		
		var counter = 0
		
		for formAndTitleToAdd in formTypesWithTitles {
			var newAnimations: FormAnimations?
			let formToAdd = self.createFormWithType(formAndTitleToAdd.formType, title: formAndTitleToAdd.title, delegate: self)
			
			if counter == 0 {
				newAnimations = FormAnimations(showAnimation: startAndEndAnimations.showAnimation, dismissAnimation: middleAnimations.dismissAnimation)
			} else if counter + 1 == formTypesWithTitles.count {
				newAnimations = FormAnimations(showAnimation: middleAnimations.showAnimation, dismissAnimation: startAndEndAnimations.dismissAnimation)
			} else {
				newAnimations = middleAnimations
			}
			
			self.formsToDisplay += [FormToDisplayWithAnimations(form: formToAdd, animations: newAnimations!)]
			
			counter++
		}
	}
	
	//MARK: - Showing
	func show() {
		if currentFormNumber == -1 {
			AppDelegate.keyWindow.addSubview(self.backgroundImageView)
			self.backgroundImageView.alpha = 0.0
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.backgroundImageView.alpha = 0.2
			})
		}
		
		self.showNextForm()
	}
	
	//MARK: - Work out what the animations should be
	func selectAnimations(currentAddition: Int, totalForms: Int, showAnimation: DataEntryFormAnimationType?, dismissAnimation: DataEntryFormAnimationType?) -> FormAnimations {
		var newShowAnimation = DataEntryFormAnimationType.Bottom
		var newDismissAnimation = DataEntryFormAnimationType.Top
		
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
			formToShow.form.needsBackground = false
			formToShow.form.show(formToShow.animations.showAnimation)
		} else {
			self.dismiss()
			
			self.delegate?.dataEntryFormControllerDidFinish(self)
		}
	}
	
	func dismiss() {
		UIView.animateWithDuration(1.0, animations: { () -> Void in
			self.backgroundImageView.alpha = 0.0
			}, completion: { (completed: Bool) -> Void in
				self.backgroundImageView.removeFromSuperview()
		})
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
		self.dismiss()
		
		self.delegate?.dataEntryFormControllerDidCancel(self)
	}
	
	func DataEntryFormAmountDidFinish(amount: Float, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		
		self.delegate?.DataEntryFormAmountDidFinish?(amount, setup: setup)
		
		self.showNextForm()
	}
	
	func DataEntryFormTextDidFinish(text: String, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		
		self.delegate?.DataEntryFormTextDidFinish?(text, setup: setup)
		
		self.showNextForm()
	}
	
	func DataEntryFormDateDidFinish(date: NSDate, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		
		self.delegate?.DataEntryFormDateDidFinish?(date, setup: setup)
		
		self.showNextForm()
	}
	
	func DataEntryFormCustomDidFinish(payload: Dictionary<String, AnyObject>, setup: DataEntryForm) {
		setup.dismiss(self.formsToDisplay[currentFormNumber].animations.dismissAnimation)
		
		self.delegate?.DataEntryFormCustomDidFinish?(payload, setup: setup)
		
		self.showNextForm()
	}
}