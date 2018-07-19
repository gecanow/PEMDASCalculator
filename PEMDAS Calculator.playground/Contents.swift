//  PEMDAS Calculator
//  made on the Xcode Playground
//
//  Created by Gabrielle Ecanow on 3/20/18.
//  Copyright © 2018 Gabrielle Ecanow. All rights reserved.
//

import UIKit
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

class CalcViewController: UIViewController {
    
    var titleLabel = UILabel()
    var equationLabel = UILabel()
    var questionView = UIView()
    var equation = [String]()
    var lastWasOperator = true
    
    //=====================================================
    // VIEW DID LOAD
    //=====================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.frame = CGRect(x: 0, y: 0, width: 365, height: 500)
        setupUI()
    }
    
    //=====================================================
    // Removes the last character in the equation
    //=====================================================
    @IBAction func tappedUndo(_ sender: Any) {
        if equation.count > 0 {
            equationLabel.text!.remove(at: equationLabel.text!.index(before: equationLabel.text!.endIndex))
            equation[equation.count-1].remove(at: equation[equation.count-1].index(before: equation[equation.count-1].endIndex))
            if equation[equation.count-1] == "" {
                equation.remove(at: equation.count-1)
                lastWasOperator = !lastWasOperator
            }
        }
    }
    
    //=====================================================
    // Handles when a number is tapped
    //=====================================================
    @IBAction func tappedNum(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.equationLabel.text = self.equationLabel.text! + String(sender.tag)
        }
        
        if lastWasOperator {
            equation.append(String(sender.tag))
        } else {
            equation[equation.count-1] = equation[equation.count-1] + String(sender.tag)
        }
        lastWasOperator = false
    }
    
    //=====================================================
    // Handles when the dot is tapped
    //=====================================================
    @IBAction func tappedDot(_ sender: Any) {
        if (equation.count > 0 && Int(equation[equation.count-1]) != nil) {
            equation[equation.count-1] = equation[equation.count-1] + "."
            updateText()
            lastWasOperator = false
        }
    }
    
    //=====================================================
    // Handles when an operator is tapped
    //=====================================================
    @IBAction func tappedOperator(_ sender: UIButton) {
        if (!lastWasOperator) {
            equationLabel.text = equationLabel.text! + sender.currentTitle!
            equation.append(sender.currentTitle!)
            lastWasOperator = true
        }
    }
    
    //=====================================================
    // Handles when the parenthesis is tapped
    //=====================================================
    @IBAction func tappedParen(_ sender: UIButton) {
        if sender.currentTitle == ")" && !lastWasOperator {
            equationLabel.text = equationLabel.text! + sender.currentTitle!
            equation.append(sender.currentTitle!)
            lastWasOperator = false
        } else if sender.currentTitle == "(" {
            if !lastWasOperator {
                equationLabel.text = equationLabel.text! + "x" + sender.currentTitle!
                equation.append("x")
                equation.append(sender.currentTitle!)
            } else {
                equationLabel.text = equationLabel.text! + sender.currentTitle!
                equation.append(sender.currentTitle!)
            }
            lastWasOperator = true
        } else {}
    }
    
    //=====================================================
    // Updates the UI text
    //=====================================================
    func updateText() {
        equationLabel.text = ""
        for part in equation { equationLabel.text = equationLabel.text! + part }
    }
    
    //=====================================================
    // Handles when "=" is tapped
    //=====================================================
    @IBAction func tappedEquals(_ sender: Any) {
        if !hasAnError() {
            while equation.count > 1 {
                equation = breakDownEquation(from: equation)
            }
        }
        updateText()
    }
    
    //=====================================================
    // Handles when the "break down" button is tapped
    // (which solves the equation one step at a time
    //=====================================================
    @IBAction func breakDown(_ sender: Any) {
        if !hasAnError() {
            equation = breakDownEquation(from: equation)
        }
        updateText()
    }
    
    //=====================================================
    // Handles when the input has an error
    //=====================================================
    func hasAnError() -> Bool {
        // first check for an ending operator
        if lastWasOperator {
            equation.append("0")
            lastWasOperator = false
        }
        
        var numOpen = 0, numClosed = 0
        for i in equation {
            if i == "(" { numOpen+=1 }
            if i == ")" { numClosed+=1 }
        }
        
        let diff = abs(numOpen-numClosed)
        if diff == 0 {
            return false
        } else {
            for _ in 0..<diff {
                if numOpen < numClosed { equation.insert("(", at: 0) }
                else { equation.append(")") }
            }
            return true
        }
    }
    
    //=====================================================
    // Handles breaking down the equation
    //=====================================================
    func breakDownEquation(from: [String]) -> [String] {
        if from.contains("(") {
            var iEnd = Int(from.index(of: ")")!)
            
            var iStart = 1
            for i in 0..<iEnd {
                if from[i] == "(" { iStart = i+1 }
            }
            
            var tempArr = [String]()
            for part in iStart..<iEnd {
                tempArr.append(from[part])
            }
            
            let solved = solveSimple(equations: tempArr)
            if solved.count == 1 {
                iStart -= 1
                iEnd += 1
            }
            
            var returnArr = [String]()
            for part in 0..<iStart {
                returnArr.append(from[part])
            }
            returnArr.append(contentsOf: solved)
            for part in iEnd..<from.count {
                returnArr.append(from[part])
            }
            
            return returnArr
        } else {
            return solveSimple(equations: from)
        }
    }
    
    //=====================================================
    // Handles solving a simple equation
    //=====================================================
    func solveSimple(equations: [String]) -> [String] {
        var outputArr = equations
        
        if outputArr.contains("^") {
            outputArr = findAndSolve(type: "^", fromArr: outputArr)
        } else if outputArr.contains("x") || outputArr.contains("/") {
            if indexOf(type: "x", inArr: outputArr) < indexOf(type: "/", inArr: outputArr) {
                outputArr = findAndSolve(type: "x", fromArr: outputArr)
            } else {
                outputArr = findAndSolve(type: "/", fromArr: outputArr)
            }
        } else if outputArr.contains("+")  || outputArr.contains("-") {
            if indexOf(type: "+", inArr: outputArr) < indexOf(type: "-", inArr: outputArr) {
                outputArr = findAndSolve(type: "+", fromArr: outputArr)
            } else {
                outputArr = findAndSolve(type: "-", fromArr: outputArr)
            }
        } else {}
        
        return outputArr
    }
    
    //=====================================================
    // Returns the index of a certain string in an arr
    //=====================================================
    func indexOf(type: String, inArr: [String]) -> Int {
        if inArr.contains(type) {
            return inArr.index(of: type)!
        } else {
            return inArr.count + 100
        }
    }
    
    //=====================================================
    // Finds and solves certain types of equations
    //=====================================================
    func findAndSolve(type: String, fromArr: [String]) -> [String] {
        let index = fromArr.index(of: type)!
        let numBefore = Double(fromArr[Int(index)-1])
        let numAfter = Double(fromArr[Int(index)+1])
        
        var newNum = 0.0
        if type == "^" {
            newNum = pow(numBefore!, numAfter!)
        } else if type == "x" {
            newNum = numBefore! * numAfter!
        } else if type == "/" {
            newNum = numBefore! / numAfter!
        } else if type == "+" {
            newNum = numBefore! + numAfter!
        } else if type == "-" {
            newNum = numBefore! - numAfter!
        } else {}
        
        return replaceRange(with: String(newNum), from: Int(index)-1, to: Int(index)+1, inside: fromArr)
    }
    
    //=====================================================
    // Replaces a range of elements with a single string
    // within an array
    //=====================================================
    func replaceRange(with: String, from: Int, to: Int, inside: [String]) -> [String] {
        var tempArr = [String]()
        for index in 0..<from {
            tempArr.append(inside[index])
        }
        tempArr.append(with)
        for index in (to+1)..<inside.count {
            tempArr.append(inside[index])
        }
        return tempArr
    }
    
    //=====================================================
    // Handles when the clear button is tapped
    //=====================================================
    @IBAction func onTappedClear(_ sender: Any) {
        equationLabel.text = ""
        equation = [String]()
        lastWasOperator = true
    }
    
    @IBAction func tappedQuestion(_ sender: Any) {
        questionView.isHidden = !questionView.isHidden
    }
    
    //==============//
    // UI SETUP     //
    //==============//
    func setupUI() {
        
        // equation label
        let outerBox = UIView(frame: CGRect(x: 25, y: 50, width: self.view.frame.width-55, height: 40))
        outerBox.layer.borderWidth = 2
        outerBox.layer.backgroundColor = UIColor.green.cgColor
        equationLabel = UILabel(frame: CGRect(x: 2, y: 2, width: outerBox.frame.width-8, height: 36))
        equationLabel.text = ""
        equationLabel.textAlignment = .right
        equationLabel.font = UIFont(name: "Helvetica", size: 25)
        outerBox.addSubview(equationLabel)
        self.view.addSubview(outerBox)
        
        // numbered buttons
        var ctr = 9
        for r in 0...3 {
            for c in stride(from: 2, to: -1, by: -1) {
                let newButton = UIButton(frame: CGRect(x: 25+88*c, y: 140+88*r, width: 80, height: 80))
                newButton.layer.borderWidth = 2
                newButton.setTitleColor(.black, for: .normal)
                newButton.titleLabel?.font = UIFont(name: "Helvetica", size: 60)
                if ctr >= 0 {
                    newButton.setTitle("\(ctr)", for: .normal)
                    newButton.tag = ctr
                    newButton.addTarget(self, action: #selector(tappedNum(_:)), for: .touchUpInside)
                    self.view.addSubview(newButton)
                } else if ctr == -1 {
                    newButton.setTitle(".", for: .normal)
                    newButton.addTarget(self, action: #selector(tappedDot(_:)), for: .touchUpInside)
                } else {
                    newButton.setTitle("?", for: .normal)
                    newButton.setTitleColor(.orange, for: .normal)
                    newButton.layer.borderColor = UIColor.orange.cgColor
                    newButton.backgroundColor = UIColor.white
                    newButton.addTarget(self, action: #selector(tappedQuestion(_:)), for: .touchUpInside)
                }
                self.view.addSubview(newButton)
                ctr-=1
            }
        }
        
        // operations
        let openP = UIButton(frame: CGRect(x: 25, y: 95, width: 40, height: 40))
        openP.setTitle("(", for: .normal)
        openP.addTarget(self, action: #selector(tappedParen(_:)), for: .touchUpInside)
        
        let closedP = UIButton(frame: CGRect(x: 70, y: 95, width: 40, height: 40))
        closedP.setTitle(")", for: .normal)
        closedP.addTarget(self, action: #selector(tappedParen(_:)), for: .touchUpInside)
        
        let exp = UIButton(frame: CGRect(x: 115, y: 95, width: 40, height: 40))
        exp.setTitle("^", for: .normal)
        exp.addTarget(self, action: #selector(tappedOperator(_:)), for: .touchUpInside)
        
        let add = UIButton(frame: CGRect(x: 160, y: 95, width: 40, height: 40))
        add.setTitle("+", for: .normal)
        add.addTarget(self, action: #selector(tappedOperator(_:)), for: .touchUpInside)
        
        let sub = UIButton(frame: CGRect(x: 205, y: 95, width: 40, height: 40))
        sub.setTitle("-", for: .normal)
        sub.addTarget(self, action: #selector(tappedOperator(_:)), for: .touchUpInside)
        
        let mult = UIButton(frame: CGRect(x: 250, y: 95, width: 40, height: 40))
        mult.setTitle("x", for: .normal)
        mult.addTarget(self, action: #selector(tappedOperator(_:)), for: .touchUpInside)
        
        let div = UIButton(frame: CGRect(x: 295, y: 95, width: 40, height: 40))
        div.setTitle("/", for: .normal)
        div.addTarget(self, action: #selector(tappedOperator(_:)), for: .touchUpInside)
        
        for o in [openP, closedP, exp, add, sub, mult, div] {
            o.layer.borderWidth = 2
            o.layer.cornerRadius = 20
            o.backgroundColor = UIColor.white
            o.layer.borderColor = UIColor.blue.cgColor
            o.titleLabel?.font = UIFont(name: "Helvetica", size: 25)
            o.setTitleColor(.blue, for: .normal)
            self.view.addSubview(o)
        }
        
        // commands
        let step = UIButton(frame: CGRect(x: 290, y: 140, width: 45, height: 80))
        step.setTitle("⧐", for: .normal)
        step.addTarget(self, action: #selector(breakDown(_:)), for: .touchUpInside)
        
        let equals = UIButton(frame: CGRect(x: 290, y: 228, width: 45, height: 80))
        equals.setTitle("=", for: .normal)
        equals.addTarget(self, action: #selector(tappedEquals(_:)), for: .touchUpInside)
        
        let clear = UIButton(frame: CGRect(x: 290, y: 316, width: 45, height: 80))
        clear.setTitle("c", for: .normal)
        clear.addTarget(self, action: #selector(onTappedClear(_:)), for: .touchUpInside)
        
        let undo = UIButton(frame: CGRect(x: 290, y: 404, width: 45, height: 80))
        undo.setTitle("⟲", for: .normal)
        undo.addTarget(self, action: #selector(tappedUndo(_:)), for: .touchUpInside)
        
        for c in [step, equals, clear, undo] {
            c.layer.borderWidth = 2
            c.backgroundColor = UIColor.white
            c.setTitleColor(.red, for: .normal)
            c.titleLabel?.font = UIFont(name: "Helvetica", size: 30)
            c.layer.borderColor = UIColor.red.cgColor
            self.view.addSubview(c)
        }
        
        // title
        titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 345, height: 20))
        titleLabel.text = "PEMDAS Calculator"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Helvetica", size: 25)
        self.view.addSubview(titleLabel)
        
        // information
        questionView.frame = CGRect(x: 20, y: 20, width: 325, height: 460)
        questionView.layer.borderWidth = 1
        questionView.backgroundColor = .white
        
        let questionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 325, height: 420))
        questionLabel.text = "Welcome to the PEMDAS Calculator!\n\nThe ORDER of OPERATIONS is very important to mathematics. Mathematicians learn from a young age that first you solve what is inside the parenthases, then exponents, then multiplication and division, and, finally, addition and subtraction. What better way is there to memorize these steps than through using a calculator that specializes in the order of operations!\n\nClick ⧐ to see how the equation is solved step-by-step. Click = to jump straight to the answer. Click c to clear the screen, and click ⟲ to undo your last move."
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.lineBreakMode = .byWordWrapping
        
        let gotIt = UIButton(frame: CGRect(x: 125, y: 420, width: 53, height: 20)) //122, 420
        gotIt.setTitle("Got It!", for: .normal)
        gotIt.backgroundColor = UIColor.blue
        gotIt.addTarget(self, action: #selector(tappedQuestion(_:)), for: .touchUpInside)
        
        questionView.addSubview(questionLabel)
        questionView.addSubview(gotIt)
        
        self.view.addSubview(questionView)
    }
}

let myVC = CalcViewController()
PlaygroundPage.current.liveView = myVC.view
PlaygroundPage.current.needsIndefiniteExecution = true
