//
//  ViewController.swift
//  JogShuttle
//
//  Created by Mats on 12.01.23.
//

import Cocoa
import IOKit

class ViewController: NSViewController, Jd1Delegate {
    var jd1: Jd1?
    
    func onDeviceAttached() {
        print("JD1 device attached")
        jd1?.setLED_State(2)
    }
    
    func onDeviceRemoved() {
        print("JD1 device removed")
    }
    
    func onJD1ButtonClicked(_ button: buttons) {
        switch button {
        case .Button1:
            print("Button '1' pressed.")
        case .Button2:
            print("Button '2' pressed.")
        case .Button3:
            print("Button '3' pressed.")
        case .Button4:
            print("Button '4' pressed.")
        case .Button5:
            print("Button '5' pressed.")
        case .ButtonDeckFile:
            print("Button 'Deck/File' pressed.")
        case .ButtonLeft:
            print("Button 'left' pressed.")
        case .ButtonRight:
            print("Button 'right' pressed.")
        case .ButtonCapUndo:
            print("Button 'Cap/Undo' pressed.")
        case .ButtonIn:
            print("Button 'In' pressed.")
        case .ButtonOut:
            print("Button 'Out' pressed.")
        case .ButtonPlayPause:
            print("Button 'Play/Pause' pressed.")
        case .ButtonAddDiv:
            print("Button 'Add/Div' pressed.")
        case .ButtonWheelCenter:
            print("Button 'Wheel center' pressed.")
        @unknown default:
            print("unknown Button pressed.")
        }
    }
    
    func onJD1WheelTurned(_ turnedClockwise: Bool) {
        print("wheel in swift: \(turnedClockwise)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        jd1 = Jd1()
        jd1?.initializeJd1()
        jd1?.delegate = self
    }
}
