/* ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
The MIT License (MIT)

Copyright (c) 2015 Carl Goldsmith

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-- */

import Foundation
import UIKit

class DataEntryFormDate : DataEntryForm {
	private var _datePicker: UIDatePicker?
	var datePicker: UIDatePicker {
		if _datePicker == nil {
			_datePicker = UIDatePicker()
			_datePicker!.setTranslatesAutoresizingMaskIntoConstraints(false)
			_datePicker!.date = NSDate()
			_datePicker!.datePickerMode = .DateAndTime
			_datePicker!.minimumDate = NSDate()
			_datePicker!.minuteInterval = 5
		}
		
		return _datePicker!
	}
	
	//MARK: - Initialisers
	convenience init(title: String?, delegate: DataEntryFormDelegate, dates: (minimumDate: NSDate?, maximumDate: NSDate?, startDate: NSDate?)?) {
		
		self.init(title: title, type: .Date, delegate: delegate)
		if let unwrappedDates = dates {
			if unwrappedDates.minimumDate != nil {
				self.datePicker.minimumDate = unwrappedDates.minimumDate!
			}
			if unwrappedDates.maximumDate != nil {
				self.datePicker.maximumDate = unwrappedDates.maximumDate!
			}
			if unwrappedDates.startDate != nil {
				self.datePicker.date = unwrappedDates.startDate!
			}
		}
	}
	
	required init(title: String?, type: DataEntryFormType, delegate: DataEntryFormDelegate) {
		super.init(title: title, type: type, delegate: delegate)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.formType = .Date
	}
	
	
	//MARK: - Display lifecycle
	override func willShow() {
		
	}
	
	override func didShow() {
		
	}
	
	override func willDisappear() {
		
	}
	
	override func didDisappear() {
		
	}
	
	//MARK: - Setup
	override func drawView() {
		self.contentView.addSubview(self.datePicker)
		
		var constraints = Array<AnyObject>()
		var viewsDict: Dictionary<String, UIView> = ["datePicker" : self.datePicker]
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[datePicker]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[datePicker]|", options: nil, metrics: nil, views: viewsDict)
		
		self.contentView.addConstraints(constraints)
	}
	
	override func drawViewUpdate() {
		
	}
	
	//MARK: - Done and Cancel Buttons
	override func cancelButtonPressed(sender: AnyObject) {
		self.delegate?.DataEntryFormDidCancel(self)
	}
	
	override func doneButtonPressed(sender: AnyObject) {
		self.delegate?.DataEntryFormDateDidFinish?(self.datePicker.date, setup: self)
	}
	
	//MARK: - Methods Designed for Overriding
	override func preferredViewHeight() -> CGFloat {
		return self.datePicker.frame.size.height
	}
	
	//If the view behaves oddly when being dismissed, it is worth trying to override these
	//	override func pushMagnitude() -> CGFloat {}
	//	override func gravityMagnitude() -> CGFloat {}
}


