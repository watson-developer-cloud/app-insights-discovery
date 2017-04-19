/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import Charts
import SwiftyJSON

class GraphViewController: UIViewController {
    
    let discoveryManager = DiscoveryManager.sharedInstance
    
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet var graphTitle: UILabel!
    
    // Array to store all dates in order to make graph title.
    var allDates = [Date]() {
        didSet {
            updateGraphTitle(dates: allDates)
        }
    }
    
    // Name of app, used when querying Discovery service
    fileprivate var appName:String? = nil {
        didSet {
            // Run on main thread
            DispatchQueue.main.async { [weak self] in
                // Fetch reviews
                self?.fetchData()
            }
        }
    }
    
    var sentiments = [GraphSentiment]() {
        didSet {
            DispatchQueue.main.async {
                self.updateLineChartWithData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.d
    }
    
    func fetchData() {
        guard let name = self.appName else { return }
        discoveryManager.queryForSentiment(
            appName: name,
            onSuccess: { [weak self] graphSentiments in
                self?.sentiments = graphSentiments
            },
            onFailure: { error in
                print("Error when querying discovery for graph sentiments: \(error)")
        })
    }
    
    func transformDateToString(date: String) -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let formattedDate = dateFormatter.date(from: date) {
            // convert Date to TimeInterval (typealias for Double)
            let timeInterval = formattedDate.timeIntervalSince1970
            
            // convert to Integer
            let timeSincePOSIX = Int(timeInterval)
            return Double(timeSincePOSIX)
        } else {
            return 0.0
        }
    }
    
    // Separate postive, negative values into their corresponding arrays
    // Convert date into readable time/date val
    // Date == x val, y == sentiment.
    func updateLineChartWithData() {
        var positiveSentimentEntries: [ChartDataEntry] = []
        var negativeSentimentEntries: [ChartDataEntry] = []
        for sentimentData in sentiments {
            let numPositiveReviews = Double(sentimentData.positiveSentiment.matchingResults)
            let numNegativeReviews = Double(sentimentData.negativeSentiment.matchingResults)
            let time = transformDateToString(date: sentimentData.date)
            positiveSentimentEntries.append(ChartDataEntry(x: time, y: numPositiveReviews))
            negativeSentimentEntries.append(ChartDataEntry(x: time, y: numNegativeReviews))
        }
        
        let positiveReviewsDataSet = LineChartDataSet(values: positiveSentimentEntries, label: "Positive Sentiment Reviews")
        positiveReviewsDataSet.circleHoleRadius = 0.0
        positiveReviewsDataSet.lineWidth = 2.0
        positiveReviewsDataSet.circleRadius = 10.0
        positiveReviewsDataSet.setColor(UIColor.customSickGreen())
        positiveReviewsDataSet.setCircleColor(UIColor.customSickGreen())
        positiveReviewsDataSet.setDrawHighlightIndicators(false)
        // Remove data point labels above each point.
        positiveReviewsDataSet.drawValuesEnabled = false
        
        // Fill gradient
        positiveReviewsDataSet.drawFilledEnabled = true
        positiveReviewsDataSet.fillColor = UIColor.customSickGreen()
        positiveReviewsDataSet.fillAlpha = 0.1
        
        let negativeReviewsDataSet = LineChartDataSet(values: negativeSentimentEntries, label: "Negative Sentiment Reviews")
        negativeReviewsDataSet.circleHoleRadius = 0.0
        negativeReviewsDataSet.lineWidth = 2.0
        negativeReviewsDataSet.circleRadius = 10.0
        negativeReviewsDataSet.setColor(UIColor.customRedColor())
        negativeReviewsDataSet.setCircleColor(UIColor.customRedColor())
        negativeReviewsDataSet.setDrawHighlightIndicators(false)
        // Remove data point labels above each point.
        negativeReviewsDataSet.drawValuesEnabled = false
        
        // Fill gradient
        negativeReviewsDataSet.drawFilledEnabled = true
        negativeReviewsDataSet.fillColor = UIColor.customRedColor()
        negativeReviewsDataSet.fillAlpha = 0.1
        
        let chartData = LineChartData(dataSets: [positiveReviewsDataSet, negativeReviewsDataSet])
        graphView.data = chartData

        graphView.xAxis.valueFormatter = DefaultAxisValueFormatter.with(block:
            { (value, axis) -> String in
                let date = Date(timeIntervalSince1970: value)
                self.allDates.append(date)
                // Setting output date format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/dd"
                
                // Use defined date format to format date
                let dateString = dateFormatter.string(from: date)
                return dateString
        })

        // Set up colors
        graphView.backgroundColor = UIColor.customBackgroundColor()
        graphView.chartDescription?.text = "reviews"
        graphView.chartDescription?.textColor = UIColor.customWhiteOpacityHalfColor()
        graphView.xAxis.labelTextColor = UIColor.customWhiteOpacityHalfColor()
       
        // Change X-Axis grid color
        graphView.xAxis.gridColor = UIColor.customWhiteOpacityTenColor()
        graphView.xAxis.axisLineColor = UIColor.customBackgroundColor()

        // Remove left Y-axis
        var leftYAxis = graphView.getAxis(YAxis.AxisDependency.left)
        leftYAxis.enabled = false
        
        // Format right Y-axis
        var rightYAxis = graphView.getAxis(YAxis.AxisDependency.right)
        rightYAxis.labelTextColor = UIColor.customWhiteOpacityHalfColor()
        rightYAxis.gridColor = UIColor.customWhiteOpacityTenColor()
        rightYAxis.axisLineColor = UIColor.customBackgroundColor()
        
        // Format chart legend
        var legend = graphView.legend
        legend.textColor = UIColor.customWhiteOpacityHalfColor()
        
        // Remove graph border
        graphView.borderLineWidth = 0
        
        graphView.fitScreen()
        
    }
    
    func updateGraphTitle(dates: [Date]) {
        var title = formatDateRangeToMonthYearString(date: dates[0])

        if dates.count > 1 {
            let lastDate = formatDateRangeToMonthYearString(date: dates[dates.count-1])
            if title != lastDate {
                title.append(" - \(lastDate)")
            }
        }
        graphTitle.text = title
        graphTitle.textColor = UIColor.white
        graphTitle.font = UIFont.boldSFNSDisplay(size: 15)
    }
    
    func formatDateRangeToMonthYearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

// MARK: API
extension GraphViewController {
    
    // Set the app name to query
    func setModel(appName:String) {
        self.appName = appName
    }
    
}
