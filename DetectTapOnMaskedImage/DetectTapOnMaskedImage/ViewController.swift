//
//  ViewController.swift
//  TapOnDangerousArea1
//
//  Created by Alyona on 4/28/20.
//  Copyright © 2020 alyona. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

	@IBOutlet weak var answerButton: UIButton!
	@IBOutlet weak var explainButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!

	// this image view keeps image of question, or answer, or explanation depending on the current step state
	@IBOutlet weak var imageView: UIImageView!

	// this image view keeps mask for the original image of question
	@IBOutlet weak var maskImageView: UIImageView!

	// this label presents text of question or answer
	@IBOutlet weak var quizTextLabel: UILabel!

	// this label present message "Found N dangers out of M"
	@IBOutlet weak var dangersFound: UILabel!

	// this label presents caption i.e. "question" or "answer"
	@IBOutlet weak var stateLabel: UILabel!

	// this variable keeps the data for UI
	var state: QuizFlowState = QuizFlowState() {
		didSet {
			renderState(state)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		renderState(state)
	}


	func renderState(_ state: QuizFlowState){

		let stepData = state.currentStepData

		switch(state.stepState){

			case .question:
				self.answerButton.isHidden = !state.canGoForward
				self.explainButton.isHidden = true
				self.nextButton.isHidden = true

				self.stateLabel.text = "Question"

				if let maskImageName = stepData.question.image.mask?.mask {
					self.maskImageView.image = UIImage(named: maskImageName)
				}

				self.imageView.image = UIImage(named: stepData.question.image.original)
				self.quizTextLabel.text = stepData.question.text
				self.dangersFound.text = state.dangersFoundLabel
			break

			case .answer:
				self.answerButton.isHidden = true
				self.explainButton.isHidden = false
				self.nextButton.isHidden = true

				self.stateLabel.text = "Answer"
				self.imageView.image = UIImage(named: stepData.answer.image.original)
				self.quizTextLabel.text = stepData.answer.text
				self.dangersFound.text = nil
			break

			case .explanation:
				self.answerButton.isHidden = true
				self.explainButton.isHidden = true
				self.nextButton.isHidden = false

				self.stateLabel.text = nil
				self.dangersFound.text = nil
				self.imageView.image = UIImage(named: stepData.explanation.image.original)
				self.quizTextLabel.text = stepData.explanation.text

			break
		}
	}


	@IBAction func didTapOnImage(_ sender: UITapGestureRecognizer) {

		let point = sender.location(in: imageView)
		let selectedColor = self.maskImageView.colorOfPoint(point: point)

		var newState = self.state

		newState.registerSelectedColor(selectedColor)

		self.state = newState

//		let currentImage = images[currentImageIndex]
//
//		if dangerousMaskColors.contains(selectedColor) // user tapped on dangerous area
//		{
//			// save mask color of danger which user has found
//			foundColorsForCurrentImage.insert(selectedColor)
//
//			// update label with results of quiz for current image
//			resultLabel.text = String(format: "%@: %d dangers found",
//									  currentImage.title,
//									  foundColorsForCurrentImage.count)
//			indicateSuccess(true)
//		}else{ // user tapped on safe area
//
//			indicateSuccess(false)
//		}
//
//		// enable NEXT button when user selected all dnagers for current image
//		self.nextButton.isEnabled = foundColorsForCurrentImage.count == currentImage.numerOfDangers
	}

	@IBAction func onNextButtonTapped(_ sender: Any) {
		var newState = self.state
		newState.switchToNextStep()
		self.state = newState
	}

	@IBAction func onExplainButtonTapped(_ sender: Any) {
		var newState = self.state
		newState.switchToExplanationState()
		self.state = newState
	}


	@IBAction func onAnswerButtonTapped(_ sender: Any) {
		var newState = self.state
		newState.switchToAnswerState()
		self.state = newState
	}

//	fileprivate func indicateSuccess(_ success: Bool) {
//		//indicate success/fail of current attepmt
//		if success {
//			self.hitReactionLabel.text = "Correct!"
//			self.hitReactionLabel.textColor = .systemGreen
//		}else{
//			self.hitReactionLabel.text = "Nope..."
//			self.hitReactionLabel.textColor = .systemRed
//		}
//	}

//	fileprivate func updateStateForCurrentImageIndex(){
//		let currentImage = images[currentImageIndex]
//		imageView.image = UIImage.init(named: currentImage.original)
//		maskImage.image = UIImage.init(named: currentImage.mask)
//	}


//	fileprivate func goToNextImage(){
//		foundColorsForCurrentImage.removeAll()
//		resultLabel.text = "Find all dangers here!"
//		self.hitReactionLabel.text = nil
//		self.nextButton.isEnabled = false
//
//		if currentImageIndex >= images.count - 1 {
//			currentImageIndex = 0
//		}else{
//			currentImageIndex = currentImageIndex + 1
//		}
//	}
	
}

extension UIView {
	func colorOfPoint(point: CGPoint) -> UIColor {
		let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

		var pixelData: [UInt8] = [0, 0, 0, 0]

		let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

		context!.translateBy(x: -point.x, y: -point.y)

		self.layer.render(in: context!)

		let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
		let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
		let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
		let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)

		let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)

		return color
	}
}

