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

enum DataEntryFormSetupType {
    case Amount
    case Text
    case Date
}

enum DataEntryFormSetupError {
    case noViewToBecomeInactive
}

enum DataEntryFormAnimationType {
    case Top
    case Right
    case Bottom
    case Left
}

@objc protocol DataEntryFormSetupDelegate {
    func dataEntryFormSetupDidCancel(setup: DataEntryFormSetup)
	optional func dataEntryFormSetupAmountDidFinish(amount: Float, setup: DataEntryFormSetup)
}

class DataEntryFormSetup: UIView {
	//MARK: Private Variables
	private var _contentBackground: UIVisualEffectView?
	private var contentBackground: UIVisualEffectView {
		if _contentBackground == nil {
			_contentBackground = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
			_contentBackground?.frame = self.bounds
			_contentBackground?.setTranslatesAutoresizingMaskIntoConstraints(false)
		}
		return _contentBackground!
	}
	
	
	
	var _backgroundImageView: UIImageView?
	private var backgroundImageView: UIImageView {
		if self._backgroundImageView == nil {
			self._backgroundImageView = UIImageView(frame: DataEntryFormSetup.keyWindow.bounds)
		}
		
		self._backgroundImageView?.backgroundColor = .blackColor()
		
		if backgroundNeedsRefresh {
			backgroundNeedsRefresh = false
		}
		return self._backgroundImageView!
	}
	
    private var tempImage: UIImageView!
	private var cancelButton = UIButton.buttonWithType(.System) as! UIButton
	private var doneButton = UIButton.buttonWithType(.System) as! UIButton
	
	private var _contentView: UIView?
	private var _snapBehaviour: UISnapBehavior?
	private var _pushBehaviour: UIPushBehavior?
	private var _gravityBehaviour: UIGravityBehavior?
	private var _preferredViewHeight: CGFloat?
	
    //MARK:Dynamic Animators
    let snapBehaviourDamping: CGFloat = 0.5
    let pushMagnitude: CGFloat = 200.0
    let gravityMagnitude: CGFloat = 20.0
    
    var animator: UIDynamicAnimator?
	var pushBehaviour: UIPushBehavior {
		set {
			self._pushBehaviour = newValue
		}
		get {
			if self._pushBehaviour == nil {
				self._pushBehaviour = UIPushBehavior(items: [self], mode: .Instantaneous)
			}
			
			return self._pushBehaviour!
		}
	}
    
    //Reusable dynamic behaviours
	var snapBehaviour: UISnapBehavior {
		get {
			if _snapBehaviour == nil {
				self._snapBehaviour = UISnapBehavior(item: self, snapToPoint: DataEntryFormSetup.keyWindow.center)
				self._snapBehaviour?.damping = snapBehaviourDamping
				
				return self._snapBehaviour!
			}
			
			return _snapBehaviour!
		}
		
		set {
			_snapBehaviour = newValue
		}
    }
	
    var noRotation: UIDynamicItemBehavior {
        let noRot = UIDynamicItemBehavior(items: [self])
        noRot.allowsRotation = false
        return noRot
    }
	
	var gravityBehaviour: UIGravityBehavior {
		set {
			self._gravityBehaviour = newValue
		}
		
		get {
			if self._gravityBehaviour == nil {
				self._gravityBehaviour = UIGravityBehavior(items: [self])
			}
			
			return self._gravityBehaviour!
		}
	}
	
	private var _resistanceBehaviour: UIDynamicItemBehavior?
    var resistanceBehaviour: UIDynamicItemBehavior {
		if _resistanceBehaviour == nil {
			_resistanceBehaviour = UIDynamicItemBehavior(items: [self])
		}
        _resistanceBehaviour!.resistance = 10.0
        return _resistanceBehaviour!
    }
	
    
    //MARK: Class Variables
    static var keyWindow: UIWindow = {
        return UIApplication.sharedApplication().keyWindow
        }()!
    static var blurredBackgroundImage: UIImage {
        let snapshot = self.keyWindow.takeSnapshot()
		let blurredSnapshot = snapshot.applyDarkEffect()
        
        return blurredSnapshot!
    }
	
	//MARK: Variables designed to be altered
	var formTitle: String?
	var formType: DataEntryFormSetupType
	var delegate: DataEntryFormSetupDelegate?
	
	var needsBackground = true //by default this is true; a DataEntrySetupController may override this if it is providing its own background
	var backgroundNeedsRefresh = true //override this to force a screenshot to be taken again
	var shouldBounce = true //a DataEntrySetupController may override this to make animating between views look better
	
	var contentView: UIView {
		if _contentView == nil {
			_contentView = UIView()
			_contentView?.setTranslatesAutoresizingMaskIntoConstraints(false)
		}
		return _contentView!
	}
    
    
    //MARK: - Initialisers
    required init(title: String?, type: DataEntryFormSetupType, delegate: DataEntryFormSetupDelegate) {
        self.formTitle = title
        self.delegate = delegate
        self.formType = type
		
		var firstSize: CGFloat = 0.0
		
		if DataEntryFormSetup.keyWindow.frame.size.width * 0.95 < 300 {
			firstSize = DataEntryFormSetup.keyWindow.frame.size.width * 0.95
		} else {
			firstSize = 300.0
		}
		
        super.init(frame: CGRectMake(0, 0, firstSize, firstSize))
        
		self.backgroundColor = .clearColor()
		self.layer.cornerRadius = 20.0
		self.clipsToBounds = true
		
		self.firstDrawView()
		self.drawView()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceDidRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        //ANY INITIAL VISUAL UPDATES MUST BE DONE BEFORE THIS POINT
        
        let image = self.takeSnapshot()
        self.tempImage = UIImageView(image: image)
        self.tempImage.frame = self.bounds
        self.addSubview(tempImage)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.formType = .Amount
        
        super.init(coder: aDecoder)
    }
    
    
    //MARK: - Display lifecycle
    func willShow() {
        
    }
    
    func didShow() {
        
    }
    
    func willDisappear() {
        
    }
    
    func didDisappear() {
        
    }
	
	//MARK: - Handle Rotation
	func deviceDidRotate() {
		self.firstDrawViewUpdate()
		
		self.animator?.removeAllBehaviors()
		self.snapBehaviour = UISnapBehavior(item: self, snapToPoint: DataEntryFormSetup.keyWindow.center)
		self.animator?.addBehavior(self.snapBehaviour)
		self.animator?.addBehavior(self.resistanceBehaviour)
	}
		
    //MARK: - Setup
    func drawView() {
        
    }
	
	func drawViewUpdate() {
		
	}
	
	private func firstDrawViewUpdate() {
		//Change to the preferred height, making sure it will fit in the view
		var newFrame = self.frame
		
		if self.preferredViewHeight() < DataEntryFormSetup.keyWindow.frame.size.height {
			newFrame.size.height = self.preferredViewHeight()
		} else {
			newFrame.size.height = DataEntryFormSetup.keyWindow.frame.size.height
		}
		
		self.frame = newFrame
	}
	
	final func firstDrawView() {
		self.firstDrawViewUpdate()
		
		//Add the blur background
		self.insertSubview(self.contentBackground, atIndex: 0)
		
		var constraints = Array<AnyObject>()
		var viewsDict: Dictionary<String, UIView> = ["contentBackground" : self.contentBackground]
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentBackground]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentBackground]|", options: nil, metrics: nil, views: viewsDict)
		
		self.addConstraints(constraints)
		
		
		//Now set up the content view and the cancel/done buttons
		cancelButton.setTitle("Cancel", forState: .Normal)
		doneButton.setTitle("Done", forState: .Normal)
		
		cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
		doneButton.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: .TouchUpInside)
		doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: .TouchUpInside)
		
		let spacerX = UIView()
		let spacerY = UIView()
		
		spacerX.backgroundColor = .grayColor()
		spacerY.backgroundColor = .grayColor()
		
		spacerX.setTranslatesAutoresizingMaskIntoConstraints(false)
		spacerY.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		self.contentBackground.addSubview(self.cancelButton)
		self.contentBackground.addSubview(self.doneButton)
		self.contentBackground.addSubview(spacerX)
		self.contentBackground.addSubview(spacerY)
		self.contentBackground.addSubview(self.contentView)
		
		
		//Then create the constraints for these
		constraints = Array<AnyObject>()
		viewsDict = ["contentView" : self.contentView, "cancelButton" : self.cancelButton, "doneButton" : self.doneButton, "spacerX" : spacerX, "spacerY" : spacerY]
		let metricsDict = ["buttonHeight" : 50]
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[spacerX]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[cancelButton][spacerY(1)][doneButton(cancelButton)]|", options: .AlignAllCenterY, metrics: nil, views: viewsDict)
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView][spacerX(1)][spacerY(buttonHeight)]|", options: nil, metrics: metricsDict, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[spacerX][cancelButton]|", options: nil, metrics: nil, views: viewsDict)
		constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[spacerX][doneButton]|", options: nil, metrics: nil, views: viewsDict)
		
		self.contentBackground.addConstraints(constraints)
	}
    
    //MARK: - Display
    final func show(animationType: DataEntryFormAnimationType) {
        self.willShow()
		
		if needsBackground {
			DataEntryFormSetup.keyWindow.addSubview(self.backgroundImageView)
			self.backgroundImageView.alpha = 0.0
			println(self.backgroundImageView.alpha)
		}
        
        switch animationType {
        case .Top:
            self.center = CGPoint(x: DataEntryFormSetup.keyWindow.center.x, y: DataEntryFormSetup.keyWindow.center.y - DataEntryFormSetup.keyWindow.frame.size.height * 8)
            break
        case .Bottom:
            self.center = CGPoint(x: DataEntryFormSetup.keyWindow.center.x, y: DataEntryFormSetup.keyWindow.center.y + DataEntryFormSetup.keyWindow.frame.size.height * 8)
            break
        case .Left:
            self.center = CGPoint(x: DataEntryFormSetup.keyWindow.center.x - DataEntryFormSetup.keyWindow.frame.size.width * 10, y: DataEntryFormSetup.keyWindow.center.y)
            break
        case .Right:
            self.center = CGPoint(x: DataEntryFormSetup.keyWindow.center.x + DataEntryFormSetup.keyWindow.frame.size.width * 10, y: DataEntryFormSetup.keyWindow.center.y)
            break
        }
		
        DataEntryFormSetup.keyWindow.addSubview(self)
        
        if self.animator == nil {
            self.animator = UIDynamicAnimator(referenceView: DataEntryFormSetup.keyWindow)
        }
        
        self.animator?.addBehavior(self.snapBehaviour)
        self.animator?.addBehavior(self.noRotation)
        self.animator?.addBehavior(self.resistanceBehaviour)
		
        UIView.animateWithDuration(0.5, animations: { () -> Void in
			
		}, completion: { (Bool) -> Void in
			self.tempImage.removeFromSuperview()
			
			if self.needsBackground {
				self.backgroundImageView.alpha = 0.2
			}
			
			self.didShow()
        })
    }
    
    final func dismiss(animationType: DataEntryFormAnimationType) {
        self.willDisappear()
        
        let image = self.takeSnapshot()
        self.tempImage = UIImageView(image: image)
        self.tempImage.frame = self.bounds
        self.addSubview(tempImage)
        
        self.animator?.removeAllBehaviors()
        
        switch animationType {
        case .Top:
            self.pushBehaviour.setAngle(90.degreesToRadians, magnitude: pushMagnitude)
            self.gravityBehaviour.setAngle(270.degreesToRadians, magnitude: gravityMagnitude)
            break
        case .Bottom:
            self.pushBehaviour.setAngle(270.degreesToRadians, magnitude: pushMagnitude)
            self.gravityBehaviour.setAngle(90.degreesToRadians, magnitude: gravityMagnitude)
            break
        case .Left:
            self.pushBehaviour.setAngle(0, magnitude: pushMagnitude/2)
            self.gravityBehaviour.setAngle(180.degreesToRadians, magnitude: gravityMagnitude/2)
            break
        case .Right:
            self.pushBehaviour.setAngle(180.degreesToRadians, magnitude: pushMagnitude/2)
            self.gravityBehaviour.setAngle(0, magnitude: gravityMagnitude/2)
            break
        default:
            break
		}
		
		if shouldBounce {
			self.animator?.addBehavior(self.pushBehaviour)
		}
        self.animator?.addBehavior(self.gravityBehaviour)
        self.animator?.addBehavior(self.noRotation)
        
        self.pushBehaviour.active = true
		
		if self.needsBackground {
			UIView.animateWithDuration(0.2, animations: { () -> Void in
				}, completion: { (success: Bool) -> Void in
				self.backgroundImageView.removeFromSuperview()
			})
		}
        
        self.disappear(4.0, animated: false)
    }
    
    
    //MARK: View Cleanup
    final func disappear(delay: NSTimeInterval, animated: Bool) {
        let delay = delay * Double(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            var animationTime = 0.5
            
            if !animated {
                animationTime = 0.0
            }
            
            UIView.animateWithDuration(animationTime, animations: { () -> Void in
                self.alpha = 0.0
                self.cancelButton.alpha = 0.0
                self.doneButton.alpha = 0.0
                
                }, completion: { (Bool) -> Void in
                    self.animator?.removeAllBehaviors()
                    self.animator = nil
                    
                    self.cancelButton.removeFromSuperview()
                    self.doneButton.removeFromSuperview()
                    
                    self.removeFromSuperview()
                    
                    self.didDisappear()
            })
        })
    }
	
    //MARK: - Done and Cancel Buttons
    func cancelButtonPressed(sender: AnyObject) {
        self.delegate?.dataEntryFormSetupDidCancel(self)
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.delegate?.dataEntryFormSetupDidCancel(self)
    }
	
	//MARK: - Height
	func preferredViewHeight() -> CGFloat {
		if DataEntryFormSetup.keyWindow.frame.size.width * 0.95 < 300 {
			return DataEntryFormSetup.keyWindow.frame.size.width * 0.95
		} else {
			return 300.0
		}
	}
}