//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by 李天培 on 16/7/17.
//  Copyright © 2016年 lee. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // MARK: - Data Struct
    fileprivate enum Operation {
        case constant(Double, String)
        case random(() -> Double, String)
        case unary((Double) -> Double, (String) -> String, ((Double) -> String?)? )
        case binary((Double, Double) -> Double, (String, String) -> String, Int, ((Double, Double) -> String?)? )
        case equals
    }
    
    
    fileprivate var operations = [
        "π" : Operation.constant(M_PI, "π"),
        "e" : Operation.constant(M_E, "e"),
        "rand": Operation.random( { Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max) } , "random"),
        "√" : Operation.unary(sqrt, { "√(\($0))" }, { $0 < 0 ? "number large than zero" : nil}),
        "tan" : Operation.unary(tan, { "tan(\($0))" }, nil),
        "cos" : Operation.unary(cos, { "cos(\($0))" }, nil),
        "sin" : Operation.unary(sin, { "sin(\($0))" }, nil),
        "±" : Operation.unary(-, { "-(\($0))"}, nil),
        "%" : Operation.unary({ $0 / 100.0 }, { "(\($0))%"}, nil),
        "log₁₀" : Operation.unary(log10, { "log₁₀(\($0))" }, { $0 <= 0 ? "需要大于零" : nil}),
        "ln" : Operation.unary(log, { "ln(\($0))" }, { $0 <= 0 ? "需要大于零" : nil}),
        "x²" : Operation.unary({ $0 * $0 }, { "(\($0))²" }, nil),
        "x⁻¹" : Operation.unary({ 1.0 / $0 }, { "(\($0))⁻¹" }, { $0 != 0 ? "不可以是0" : nil}),
        "x!" : Operation.unary({ (op) in
            let operand = Int(op)
            var accumulator = 1
            for i in (2...operand).reversed() {
                accumulator *= i
            }
            return Double(accumulator)
        }, { "(\($0))!" }) {
            guard $0 >= 0 else {
                return "不可以为负"
            }
            if !$0.isInt {
                return "必须为整数"
            }
            return nil
        },
        "+" : Operation.binary(+, { "\($0) + \($1)" }, 1, nil),
        "-" : Operation.binary(-, { "\($0) - \($1)" }, 1, nil),
        "×" : Operation.binary(*, { "\($0) × \($1)" }, 2, nil),
        "÷" : Operation.binary(/, { "\($0) ÷ \($1)" }, 2, { $1 != 0 ? "不可以是0" : nil}),
        "=" : Operation.equals
    ]
    
    // MARK: - Data
    fileprivate var accumulator = 0.0
    
    fileprivate var prePriority = Int.max
    
    fileprivate var errorInformation: String?
    
    fileprivate var descriptionAccumulator = "" {
        didSet {
            if pending == nil {
                prePriority = Int.max
            }
        }
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate var internalProgram = [AnyObject]()
    
    var variableValues = [String: Double]() {
        didSet {
            if !variableValues.isEmpty {
                program = internalProgram as CalculatorBrain.PropertyList
            }
        }
    }
    
    // MARK: - Public Function
    func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = NumberFormatter.standardNumberFormatter().string(from: NSNumber(value: operand))!
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(_ variableName: String) {
        performOperation(variableName)
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let operand, let symbol):
                accumulator = operand
                descriptionAccumulator = symbol
            case .random(let function, let description):
                accumulator = function()
                descriptionAccumulator = description
            case .unary(let function, let description, let error):
                descriptionAccumulator = description(descriptionAccumulator)
                accumulator = function(accumulator)
                errorInformation = error?(accumulator)
            case .binary(let function, let description, let priority, let error):
                executePendingBinaryOperation()
                if priority > prePriority {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                prePriority = priority
                pending = PendingBinaryOperationInfo(functin: function,
                                                     firstOperand: accumulator,
                                                     descriptionFunction: description,
                                                     descriptionOperand: descriptionAccumulator,
                                                     errorFunction: error)
            case .equals:
                executePendingBinaryOperation()
                
            }
        } else {
            descriptionAccumulator = symbol
            accumulator = variableValues[symbol] ?? 0.0
        }
    }
    
    func clear() {
        removeOperations()
        variableValues.removeAll()
    }
    
    func removeOperations() {
        prePriority = Int.max
        pending = nil
        accumulator = 0.0
        descriptionAccumulator.removeAll()
        internalProgram.removeAll()
        errorInformation = nil
    }
    
    func undo() {
        internalProgram.removeLast()
        program = internalProgram as CalculatorBrain.PropertyList
    }
    
    // MARK: - Private Function
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.functin(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            errorInformation = pending!.errorFunction?(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    
    fileprivate struct PendingBinaryOperationInfo {
        var functin: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var errorFunction: ((Double, Double) -> String?)?
    }
    
    // MARK: - Readonly Properties
    var isPartialResult: Bool {
        return pending != nil
    }
    
    var description: String {
        if isPartialResult {
            return pending!.descriptionFunction(pending!.descriptionOperand,
                                                pending!.descriptionOperand != descriptionAccumulator ?
                                                    descriptionAccumulator
                                                    : "")
        }
        return descriptionAccumulator
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            removeOperations()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var error: String? {
        return errorInformation
    }
    
    var result: Double {
        return accumulator
    }
}

extension Double {
    var isInt: Bool {
        let int: Double = Double(Int(self))
        return (self - int) == 0
    }
}
