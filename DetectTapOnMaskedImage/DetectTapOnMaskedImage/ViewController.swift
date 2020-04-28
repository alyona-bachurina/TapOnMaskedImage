//
//  ViewController.swift
//  TapOnDangerousArea1
//
//  Created by Alyona on 4/28/20.
//  Copyright © 2020 alyona. All rights reserved.
//

import UIKit


struct ImageDescriptor {
	let title: String		// title of quiz step
	let original: String	// name of quiz image
	let mask: String		// name of mask image
	let numerOfDangers: Int // number of masked areas in the image
}

class ViewController: UIViewController {

	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var maskImage: UIImageView!
	@IBOutlet weak var resultLabel: UILabel!
	@IBOutlet weak var hitReactionLabel: UILabel!

	// colors, which we use on mask images to mark dangerous areas
	let dangerousMaskColors:[UIColor] = [ UIColor.red, UIColor.green, UIColor.blue ]

	// Data to present
	// ORIGINAL and MASK images MUST be same sized and have same frames
	let images:[ImageDescriptor] = [
		ImageDescriptor(title: "Nature", original:"img1", mask:"img1_mask", numerOfDangers: 2),
		ImageDescriptor(title: "Hazards", original:"img2", mask:"img2_mask", numerOfDangers: 2),
		ImageDescriptor(title: "Mixed", original:"img3", mask:"img3_mask", numerOfDangers: 3),
		ImageDescriptor(title: "Fire", original:"img4", mask:"img4_mask", numerOfDangers: 1),
	]

	// index of current presented image, intially is -1
	var currentImageIndex: Int = -1{
		didSet{
			updateStateForCurrentImageIndex()
		}
	}
	// set of mask colors, which user already tapped on current image
	var foundColorsForCurrentImage = Set<UIColor>()

	override func viewDidLoad() {
		super.viewDidLoad()

		// load first image
		self.goToNextImage()
	}

	@IBAction func didTapOnImage(_ sender: UITapGestureRecognizer) {
		let point = sender.location(in: imageView)
		let selectedColor = self.maskImage.colorOfPoint(point: point)

		let currentImage = images[currentImageIndex]

		if dangerousMaskColors.contains(selectedColor) // user tapped on dangerous area
		{
			// save mask color of danger which user has found
			foundColorsForCurrentImage.insert(selectedColor)

			// update label with results of quiz for current image
			resultLabel.text = String(format: "%@: %d dangers found",
									  currentImage.title,
									  foundColorsForCurrentImage.count)
			indicateSuccess(true)
		}else{ // user tapped on safe area

			indicateSuccess(false)
		}

		// enable NEXT button when user selected all dnagers for current image
		self.nextButton.isEnabled = foundColorsForCurrentImage.count == currentImage.numerOfDangers
	}

	@IBAction func onNextButtonTapped(_ sender: Any) {
		goToNextImage()
	}

	fileprivate func indicateSuccess(_ success: Bool) {
		//indicate success/fail of current attepmt
		if success {
			self.hitReactionLabel.text = "Correct!"
			self.hitReactionLabel.textColor = .systemGreen
		}else{
			self.hitReactionLabel.text = "Nope..."
			self.hitReactionLabel.textColor = .systemRed
		}
	}

	fileprivate func updateStateForCurrentImageIndex(){
		let currentImage = images[currentImageIndex]
		imageView.image = UIImage.init(named: currentImage.original)
		maskImage.image = UIImage.init(named: currentImage.mask)
	}


	fileprivate func goToNextImage(){
		foundColorsForCurrentImage.removeAll()
		resultLabel.text = "Find all dangers here!"
		self.hitReactionLabel.text = nil
		self.nextButton.isEnabled = false

		if currentImageIndex >= images.count - 1 {
			currentImageIndex = 0
		}else{
			currentImageIndex = currentImageIndex + 1
		}
	}
	
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
