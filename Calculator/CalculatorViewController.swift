//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by 李天培 on 16/7/12.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet fileprivate weak var accumulate: UILabel!
    
    @IBOutlet fileprivate weak var undoButton: UIButton!
    
    @IBOutlet var addtionalButtons: [UIButton]!
    // MARK: - Properties
    fileprivate var userIsInTheMiddleOfTyping = false {
        didSet {
            undoButton.setTitle(userIsInTheMiddleOfTyping ? "⬅︎" : "Undo", for: UIControlState())
        }
    }
    
    fileprivate var displayValue: Double? {
        set {
            accumulate.text = brain.description + (brain.isPartialResult ? "..." : "=")
            if let error = brain.error {
                display.text = error
            } else if let result = newValue {
                display.text = NumberFormatter.standardNumberFormatter().string(from: NSNumber(value: result))
            } else {
                display.text = "error"
            }
        }
        
        get {
            return Double(display.text!)
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    // MARK: -
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction fileprivate func touchPoint() {
        if !display.text!.contains(".") {
            display.text!.append(".")
            userIsInTheMiddleOfTyping = true
        }
    }
    

    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
    }
    
    @IBAction fileprivate func clear() {
        brain.clear()
        display.text = "0"
        accumulate.text = " "
        userIsInTheMiddleOfTyping = false
    }

    @IBAction fileprivate func backspace() {
        if userIsInTheMiddleOfTyping {
            display.text!.remove(at: display.text!.characters.index(before: display.text!.endIndex))
            if display.text!.isEmpty {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        } else {
            brain.undo()
            displayValue = brain.result
        }
    }
    
    @IBAction func addMinus(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if display.text?.characters.first == Character("-") {
                display.text?.remove(at: display.text!.startIndex)
            } else {
                display.text?.insert("-", at: display.text!.startIndex)
            }
            
        } else {
            if let lastOperation = (brain.program as? [AnyObject])?.last as? String, lastOperation == "±" {
                brain.undo()
            } else {
                performOperation(sender)
            }
        }
    }
    
    @IBAction fileprivate func setVariable(_ sender: UIButton) {
        brain.setOperand("M")
        displayValue = brain.result
    }
    
    @IBAction fileprivate func setVariableValue() {
        brain.variableValues["M"] = displayValue
        displayValue = brain.result
        userIsInTheMiddleOfTyping = false
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "ShowGraph":
            if brain.isPartialResult {
                return false
            }
        default: break
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowGraph":
                if let vc = segue.destination.contentViewController as? GraphicViewController {
                    vc.brain.program = brain.program
                    vc.navigationController?.title = brain.description
                }
            default:
                break
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        var isRegularVertical = true
        if self.traitCollection.verticalSizeClass == .compact {
            isRegularVertical = false
        }
        for button in addtionalButtons {
            button.isHidden = isRegularVertical
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController!
        } else {
            return self
        }
    }
}

extension NumberFormatter {
    static func standardNumberFormatter() -> NumberFormatter {
        let formmater = NumberFormatter()
        formmater.numberStyle = .decimal
        formmater.maximumFractionDigits = 6
        return formmater
    }
}

