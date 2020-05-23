//
//  Model.swift
//  DetectTapOnMaskedImage
//
//  Created by Alyona on 5/23/20.
//  Copyright © 2020 alyona. All rights reserved.
//

import UIKit

// Hi Ayuko!
// Let's decomopose the quiz data to data structures:

// Your input:
//- Question : picture, text
//- Answer :picture, text, button(go to explanation)
//- Explanation: picture, button(go to next question)


// This represents single step if the quiz.
struct QuizStep {
	let question: StepItem
	let answer: StepItem
	let explanation : StepItem
}

// Each step item (question/answer/explanation) can be descibed with Image and optional Text
struct StepItem {
	let image: ImageDescriptor
	let text: String?   // details text for the image
}

struct ImageDescriptor {
	let original: String
	let mask: MaskInfo?
}

struct MaskInfo {
	let mask: String		// name of mask image
	let numerOfObjects: Int // number of masked areas in the image
}


// Enum which represents the state of current step
enum StepState {
	case question, answer, explanation
}

struct QuizFlowState {

	// colors, which we use on mask images to mark dangerous areas
	var dangerousMaskColors:[UIColor] = [ UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow ]

	// set of mask colors, which user already tapped on current image
	private(set) var foundColorsForCurrentImage = Set<UIColor>()

	// Data to present
	// ORIGINAL and MASK images MUST be same sized and have same frames
	private(set) var quizData:[QuizStep] = []

	// index of current step of the quizz
	private var currentStepIndex: Int = 0

	// this veriable controls which state is now question/answer/explanation
	private(set) var stepState: StepState = .question

	init() {
		// initialize quiz data
		quizData = prepareQuizData()
	}

	// computed property which returns data for current selected step
	var currentStepData:QuizStep {
		return quizData[currentStepIndex]
	}

	var canGoForward:Bool {
		foundColorsForCurrentImage.count == currentStepData.question.image.mask?.numerOfObjects ?? 0
	}

	var dangersFoundLabel:String {
		return String(format: "Found %d dangers out of %d",
					  foundColorsForCurrentImage.count,
					  currentStepData.question.image.mask?.numerOfObjects ?? 0)
	}

	mutating func registerSelectedColor(_ selectedColor: UIColor) {
		// user tapped on dangerous area
		if dangerousMaskColors.contains(selectedColor)
		{
			// save mask color of danger which user has found
			foundColorsForCurrentImage.insert(selectedColor)
		}
	}

	mutating func switchToAnswerState(){
		self.stepState = .answer
	}

	mutating func switchToExplanationState(){
		self.stepState = .explanation
	}

	mutating func switchToNextStep(){
		if currentStepIndex >= quizData.count - 1 {
			// if current step index is equal to number of quiz steps,
			// then loop back to first element and randomize the quiz steps
			currentStepIndex = 0
			quizData = quizData.shuffled()
		}else{			
			currentStepIndex = currentStepIndex + 1
		}
		self.foundColorsForCurrentImage.removeAll()
		self.stepState = .question
	}

	// populate quiz data
	private func prepareQuizData()->[QuizStep]{

		let result:[QuizStep] = [
			// quiz step 1
			QuizStep(question: StepItem(image: ImageDescriptor(original:"apple_question",
															   mask: MaskInfo(mask:"apple_mask", numerOfObjects: 1)),
										text:"Where is the apple here?"),
					 answer: StepItem(image: ImageDescriptor(original: "apple_answer", mask: nil), text:"Here is the apple!"),
					 explanation: StepItem(image: ImageDescriptor(original: "apple_explanation", mask: nil), text: nil)),


			// quiz step 2
			QuizStep(question: StepItem(image: ImageDescriptor(original:"pear_question",
															   mask: MaskInfo(mask:"pear_mask", numerOfObjects: 2)),
										text:"Where are the pears here?"),
					 answer: StepItem(image: ImageDescriptor(original: "pear_answer", mask: nil), text:"Here are the pears!"),
					 explanation: StepItem(image: ImageDescriptor(original: "pear_explanation", mask: nil), text: nil)),


			// quiz step 3
			QuizStep(question: StepItem(image: ImageDescriptor(original:"cake_question",
															   mask: MaskInfo(mask:"cake_mask", numerOfObjects: 3)),
										text:"How many cakes do you see here?"),
					 answer: StepItem(image: ImageDescriptor(original: "cake_answer", mask: nil), text:"Correct, here are 3 cakes!"),
					 explanation: StepItem(image: ImageDescriptor(original: "cake_explanation", mask: nil), text: nil)),

			// quiz step 4
			QuizStep(question: StepItem(image: ImageDescriptor(original:"broccoli_question",
															   mask: MaskInfo(mask:"broccoli_mask", numerOfObjects: 4)),
										text:"Find all broccoli here"),
					 answer: StepItem(image: ImageDescriptor(original: "broccoli_answer", mask: nil), text:"Yep! Here are four of them"),
					 explanation: StepItem(image: ImageDescriptor(original: "broccoli_explanation", mask: nil), text: nil)),

			]
		return result
	}
}
