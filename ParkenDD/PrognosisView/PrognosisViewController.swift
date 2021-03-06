//
//  PrognosisViewController.swift
//  ParkenDD
//
//  Created by Kilian Költzsch on 30/03/15.
//  Copyright (c) 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import BEMSimpleLineGraph

class PrognosisViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var spotsAvailableLabel: UILabel!
	@IBOutlet weak var progressBar: UIProgressView!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var percentageLabel: UILabel!
	@IBOutlet weak var lineGraph: BEMSimpleLineGraphView!

	var csvData: CSV!
	var thisWeekData = [68, 77, 86, 95, 87, 82, 78, 77, 75, 74, 72, 71, 76, 79, 78, 75, 71, 67, 60, 53, 49, 45, 43, 41, 41, 40, 42, 44, 43, 45, 47, 52, 57, 62, 67, 71, 76, 79, 78, 75, 71, 64, 58, 51, 47, 43, 41, 39, 39, 40, 42, 44, 43, 45, 47, 52, 57, 62, 67, 71, 76, 79, 78, 75, 71, 64, 58, 51, 45, 38, 34, 30, 27, 27, 26, 26, 28, 32, 37, 44, 51, 58, 65, 72, 76, 79, 78, 75, 71, 64, 57, 50, 44, 37, 33, 29, 26, 26, 26, 26, 25, 28, 33, 40, 47, 54, 61, 69, 76, 79, 80, 78, 75, 69, 62, 56, 48, 40, 33, 26, 21, 19, 17, 15, 16, 17, 24, 33, 44, 54, 65, 75, 84, 93, 96, 94, 89, 80, 72, 63, 63, 62, 63, 66, 71, 79, 87, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 86, 78, 70, 62, 54, 45, 36, 27]

    override func viewDidLoad() {
        super.viewDidLoad()

		let currentDate = NSDate()

		titleLabel.text = L10n.PROGNOSISCENTRUMGALERIE.string
		let occupiedString = L10n.OCCUPIED.string
		percentageLabel.text = "15% \(occupiedString)"
		let caString = L10n.CIRCA.string
		let spotsAvailableString = L10n.SPOTSAVAILABLE.string
		spotsAvailableLabel.text = "\(caString) 892/1050 \(spotsAvailableString)"

		ServerController.sendForecastRequest("dresdencentrumgalerie", fromDate: currentDate, toDate: currentDate.dateByAddingTimeInterval(3600*24*7)) { (data) -> () in

			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.lineGraph.colorLine = UIColor.blackColor()
				self.lineGraph.reloadGraph()
			})
		}

		// Setup BEMSimpleLineGraph
		lineGraph.colorTop = UIColor.clearColor()
		lineGraph.colorBottom = UIColor.clearColor()
		lineGraph.colorPoint = UIColor.clearColor()
		lineGraph.animationGraphEntranceTime = 0.7
		lineGraph.enableBezierCurve = true

		// Feels hacky, but the graph starts animating on viewDidLoad and the data only comes in a second later
		// until that reload fires, I don't want to be showing a drawing line
		lineGraph.colorLine = UIColor.clearColor()

		datePicker.date = currentDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	/**
	Read the data from the local CSV file containing the prognosis for Centrum Galerie
	*/
	func readCSV() {
		let path = NSBundle.mainBundle().pathForResource("forecast", ofType: "csv")
		var filecontent = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)

		var error: NSErrorPointer = nil
		do {
			let csv = try CSV(fromString: filecontent)
			csvData = csv
		} catch var error1 as NSError {
			error.memory = error1
		}
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - IBActions
	// /////////////////////////////////////////////////////////////////////////

	
	@IBAction func infoButtonPressed(sender: UIButton) {
		let alertController = UIAlertController(title: L10n.FORECASTINFOTITLE.string, message: L10n.FORECASTINFOTEXT.string, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

	@IBAction func datePickerValueChanged(sender: UIDatePicker) {

		let dateWeekLater = sender.date.dateByAddingTimeInterval(3600*24*7)

//		ServerController.sendForecastRequest("dresdencentrumgalerie", fromDate: sender.date, toDate: dateWeekLater, completion: { () -> () in
//
//		})

		// The app crashes if the user changes the date before the CSV is fully parsed.
		// This takes about a second... So we'll just ignore the case if there's no csv data yet.
		if csvData == nil {
			return
		}

		var prognosis: Float = 0.0

		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let currentDateString = dateFormatter.stringFromDate(sender.date)

		for row in csvData.rows {
			if let rowDate = row["date"] where rowDate == currentDateString {
				prognosis = (row["percentage"]! as NSString).floatValue / 100
				break
			}
		}

		progressBar.progress = prognosis
		let occupiedString = L10n.OCCUPIED.string
		percentageLabel.text = "\(Int(round(prognosis*100)))% \(occupiedString)"

		let availableSpots = 1050-(1050*prognosis)
		let caString = L10n.CIRCA.string
		let spotsAvailableString = L10n.SPOTSAVAILABLE.string
		spotsAvailableLabel.text = "\(caString) \(Int(round(availableSpots)))/1050 \(spotsAvailableString)"
	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - BEMSimpleLineGraphDataSource
	// /////////////////////////////////////////////////////////////////////////

	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
//		if let csvData = csvData {
//			return csvData.rows.count
//		}
//		return 0
		return thisWeekData.count
	}

	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
//		let row = csvData.rows[index]
//		if let percentage = row["percentage"] {
//			return CGFloat((percentage as NSString).doubleValue)
//		}
//		return 0
		return CGFloat(thisWeekData[index])
	}

//	func lineGraph(graph: BEMSimpleLineGraphView!, labelOnXAxisForIndex index: Int) -> String! {
//		return thisWeekLabels[index]
//	}

//	func numberOfGapsBetweenLabelsOnLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
//		return 25
//	}

	// /////////////////////////////////////////////////////////////////////////
	// MARK: - BEMSimpleLineGraphDelegate
	// /////////////////////////////////////////////////////////////////////////
}
