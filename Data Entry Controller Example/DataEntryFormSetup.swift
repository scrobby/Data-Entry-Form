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
    //MARK: - Core Variables
    var formTitle: String?
    var formType: DataEntryFormSetupType
    var delegate: DataEntryFormSetupDelegate?
	var contentView: UIVisualEffectView {
		if _contentView == nil {
			_contentView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
			_contentView?.frame = self.bounds
			_contentView?.setTranslatesAutoresizingMaskIntoConstraints(false)
		}
		
		return _contentView!
	}
	
	var _contentView: UIVisualEffectView?
    
    var needsBackground = true //by default this is true; a DataEntrySetupController may override this if it is providing its own background
	var backgroundNeedsRefresh = true //override this to force a screenshot to be taken again
	var backgroundImageView: UIImageView {
		get {
			if self._backgroundImageView == nil {
				self._backgroundImageView = UIImageView(frame: DataEntryFormSetup.keyWindow.bounds)
			}
			
			self._backgroundImageView?.backgroundColor = .blackColor()
			
			if backgroundNeedsRefresh {
//				self._backgroundImageView!.image = DataEntryFormSetup.blurredBackgroundImage
				backgroundNeedsRefresh = false
			}
			return self._backgroundImageView!
		}
		
		set {
			self._backgroundImageView = newValue
		}
	}
	var _backgroundImageView: UIImageView?
	
	var shouldBounce = true //a DataEntrySetupController may override this to make animating between views look better
    
    
    //MARK:Dynamic Animators
    let snapBehaviourDamping: CGFloat = 0.5
    let pushMagnitude: CGFloat = 200.0
    let gravityMagnitude: CGFloat = 20.0
    
    var animator: UIDynamicAnimator?
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
    
    //These three consistent and can be added to the dynamic animator at will
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
    
    var resistanceBehaviour: UIDynamicItemBehavior {
        let resist = UIDynamicItemBehavior(items: [self])
        resist.resistance = 10.0
        return resist
    }
	
	private var _snapBehaviour: UISnapBehavior?
	private var _pushBehaviour: UIPushBehavior?
	private var _gravityBehaviour: UIGravityBehavior?
    
    //MARK: Other Variables
    var tempImage: UIImageView!
    
    var cancelButton = UIButton.buttonWithType(.System) as! UIButton
    var doneButton = UIButton.buttonWithType(.System) as! UIButton
    
    
    //MARK: Class Variables
    static var keyWindow: UIWindow = {
        return UIApplication.sharedApplication().keyWindow
        }()!
    
    class var selfHeight: CGFloat {
        return self.selfWidth
    }
    
    class var selfWidth: CGFloat {
        if DataEntryFormSetup.keyWindow.frame.size.width * 0.95 < 300 {
            return DataEntryFormSetup.keyWindow.frame.size.width * 0.95
        } else {
            return 300
        }
    }
    
    static var blurredBackgroundImage: UIImage {
        let snapshot = self.keyWindow.takeSnapshot()
		let blurredSnapshot = snapshot.applyDarkEffect()
        
        return blurredSnapshot!
    }
    
    
    //MARK: - Initialisers
    required init(title: String?, type: DataEntryFormSetupType, delegate: DataEntryFormSetupDelegate) {
        self.formTitle = title
        self.delegate = delegate
        self.formType = type
        
        super.init(frame: CGRectMake(0, 0, DataEntryFormSetup.selfWidth, DataEntryFormSetup.selfHeight))
        
        self.drawView()
        
        self.backgroundColor = .clearColor()
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
		
		self.insertSubview(self.contentView, atIndex: 0)
		
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
		println("Device did rotate")
		self.animator?.removeAllBehaviors()
		self.snapBehaviour = UISnapBehavior(item: self, snapToPoint: DataEntryFormSetup.keyWindow.center)
		self.animator?.addBehavior(self.snapBehaviour)
		self.animator?.addBehavior(self.resistanceBehaviour)
	}
		
    //MARK: - Setup
    func drawView() {
        
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
			self.createDoneCancelButtons()
			
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
    final func createDoneCancelButtons() {
        cancelButton.setTitle("Cancel", forState: .Normal)
        doneButton.setTitle("Done", forState: .Normal)
        
        cancelButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        doneButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        cancelButton.addTarget(self, action: "cancelButtonPressed:", forControlEvents: .TouchUpInside)
        doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: .TouchUpInside)
        
        DataEntryFormSetup.keyWindow.addSubview(cancelButton)
        DataEntryFormSetup.keyWindow.addSubview(doneButton)
        
        cancelButton.alpha = 0.0
        doneButton.alpha = 0.0
        
        //set up autolayout
        let items = ["cancel" : cancelButton, "done" : doneButton, "background" : self]
        let metrics = ["vertical_spacing" : 15]
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[background]-vertical_spacing-[cancel]", options: .AlignAllLeading, metrics: metrics, views: items)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[background]-vertical_spacing-[done]", options: .AlignAllTrailing, metrics: metrics, views: items)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("[cancel]->=60-[done(cancel)]", options: .AlignAllCenterY, metrics: nil, views: items)
        
        DataEntryFormSetup.keyWindow.addConstraints(constraints)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cancelButton.alpha = 1.0
            self.doneButton.alpha = 1.0
        })
    }
    
    func cancelButtonPressed(sender: AnyObject) {
        self.delegate?.dataEntryFormSetupDidCancel(self)
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.delegate?.dataEntryFormSetupDidCancel(self)
    }
}