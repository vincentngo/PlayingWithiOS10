//
//  ViewController.swift
//  ReplayKitDemo
//
//  Created by Vincent Ngo on 7/5/16.
//  Copyright © 2016 VincentNgo. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
	
	var lastPoint = CGPoint.zero
	var brushWidth: CGFloat = 5.0
	var continuous = false
	var isRecording = false
	var previewViewController: RPPreviewViewController?
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var mainImageView: UIImageView!
	@IBOutlet var recordingStatusLabel: UILabel!
	@IBOutlet var recordButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		recordingStatusLabel.text = ""
		recordButton.setTitle("Record", for: [])
	}
	
	
	@IBAction func reset(_ sender: AnyObject) {
		mainImageView.image = nil
		recordingStatusLabel.text = ""
		recordButton.setTitle("Record", for: [])
		discardRecording()
	}
	
	@IBAction func record(_ sender: AnyObject) {
		if isRecording {
			stopRecording()
		} else {
			startRecording()
		}
	}
	
	@IBAction func preview(_ sender: AnyObject) {
		if let preview = previewViewController {
			self.present(preview, animated: true, completion: nil)
		}
	}
	
}

// MARK: - Replay Kit Recording
extension ViewController {
	func startRecording() {
		let sharedRecorder = RPScreenRecorder.shared()
		sharedRecorder.startRecording { error in
			if error == nil {
				self.isRecording = true
				self.recordingStatusLabel.text = "Recording"
				self.recordButton.setTitle("Stop", for: [])
			}
		}
	}
	
	func stopRecording() {
		let sharedRecorder = RPScreenRecorder.shared()
		sharedRecorder.stopRecording { previewViewController, error in
			if error == nil {
				self.isRecording = false
				self.recordingStatusLabel.text = "Recording Stopped"
				self.previewViewController = previewViewController
				self.previewViewController?.previewControllerDelegate = self
			}
		}
	}
	
	func discardRecording() {
		let sharedRecorder = RPScreenRecorder.shared()
		sharedRecorder.discardRecording { 
			
		}
	}
}

// MARK: - RPPreviewViewControllerDelegate
extension ViewController: RPPreviewViewControllerDelegate {
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		previewController.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Drawing
extension ViewController {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		continuous = false
		if let touch = touches.first {
			lastPoint = touch.location(in: view)
		}
	}
	
	func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
		UIGraphicsBeginImageContext(view.frame.size)
		let context = UIGraphicsGetCurrentContext()
		imageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
		context?.moveTo(x: fromPoint.x, y: fromPoint.y)
		context?.addLineTo(x: toPoint.x, y: toPoint.y)
		
		context?.setLineCap(.round)
		context?.setLineWidth(brushWidth)
		context?.setStrokeColor(UIColor.black().cgColor)
		context?.setBlendMode(.normal)
		
		context?.strokePath()
		
		imageView.image = UIGraphicsGetImageFromCurrentImageContext()
		imageView.alpha = 1.0
		UIGraphicsEndImageContext()
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		continuous = true
		if let touch = touches.first {
			let currentPoint = touch.location(in: view)
			drawLine(fromPoint: lastPoint, toPoint: currentPoint)
			
			lastPoint = currentPoint
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if !continuous {
			drawLine(fromPoint: lastPoint, toPoint: lastPoint)
		}
		
		UIGraphicsBeginImageContext(mainImageView.frame.size)
		mainImageView.image?.draw(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
		imageView.image?.draw(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
		mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		imageView.image = nil
		
	}
}

