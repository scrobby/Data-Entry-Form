//
//  ViewController.swift
//  Data Entry Controller Example
//
//  Created by Carl Goldsmith on 11/08/2015.
//  Copyright (c) 2015 Carl Goldsmith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DataEntryFormDelegate {
    @IBOutlet weak var showStyleSelection: UISegmentedControl!
    @IBOutlet weak var dismissStyleSelection: UISegmentedControl!
    
    var selectedDismissStyle: DataEntryFormAnimationType {
        switch self.dismissStyleSelection.selectedSegmentIndex {
        case 0:
            return .Top
        case 1:
            return .Bottom
        case 2:
            return .Left
        case 3:
            return .Right
        default:
            return .Top
        }
    }
    
    var selectedShowStyle: DataEntryFormAnimationType {
        switch self.showStyleSelection.selectedSegmentIndex {
        case 0:
            return .Top
        case 1:
            return .Bottom
        case 2:
            return .Left
        case 3:
            return .Right
        default:
            return .Top
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissStyleSelection.selectedSegmentIndex = 0
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func valueSetupTapped(sender: AnyObject) {
        let entry = DataEntryFormAmount(title: "", delegate: self)
        entry.show(self.selectedShowStyle)
    }

    @IBAction func textSetupTapped(sender: AnyObject) {
		let entry = DataEntryFormText(title: "", delegate: self, placeholder: "Text Here")
		entry.show(self.selectedShowStyle)
    }
    
    @IBAction func dateSetupTapped(sender: AnyObject) {
		let entry = DataEntryFormDate(title: "", delegate: self, dates: nil)
		entry.show(self.selectedShowStyle)
    }
    
    @IBAction func threeSetupsTapped(sender: AnyObject) {
		
    }
	
	
	//Mark: - DataEntryFormDelegate Methods
    func DataEntryFormDidCancel(setup: DataEntryForm) {
        setup.dismiss(self.selectedDismissStyle)
    }
    
	func DataEntryFormAmountDidFinish(amount: Float, setup: DataEntryForm) {		
		setup.dismiss(self.selectedDismissStyle)
	}
	
	func DataEntryFormDateDidFinish(date: NSDate, setup: DataEntryForm) {
		setup.dismiss(self.selectedDismissStyle)
	}
	
	func DataEntryFormTextDidFinish(text: String, setup: DataEntryForm) {
		setup.dismiss(self.selectedDismissStyle)
	}
}

