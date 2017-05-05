# App Insights
App Insights is a mobile app that runs on top of IBM Bluemix. The app uses Watson Discovery service to provide analysis of reviews extracted from the top ten free apps in the App Store.

![Preview](images/app-insights.gif)

## Features

- **Sentiment Over Time:** Sentiment based on specific target phrases the [Discovery service](https://www.ibm.com/watson/developercloud/discovery.html) finds in each review.
- **Keywords:** Important topics pulled from each review.
- **Opportunities:** Reviews returned by querying the [Discovery service](https://www.ibm.com/watson/developercloud/discovery.html). Each review represents an opportunity for an app developer to discover which features to implement, change or delete.

## Building App Insights

### Prerequisites
- [Bluemix account](https://console.ng.bluemix.net/registration/?target=/catalog/services/discovery/)
- [Cloudant account](https://console.ng.bluemix.net/catalog/services/cloudant-nosql-db/) can be added onto your app through Bluemix.
- Discovery Service Instance added to your app from Bluemix as well.
- Building App Insights requires Xcode 8.x.
- Downloading app dependencies requires Carthage 0.18.1

### Setup Backend Configuration
Python is used to extract, parse and upload reviews grabbed from the App Store's RSS feeds. It then cleans the data and uploads app details into Cloudant, and app reviews into the Discovery service.

1. Install the following third-party dependencies the Python scripts require:

  ```bash
  pip install --upgrade watson-developer-cloud
  pip install cloudant
  pip install -U python-dotenv
  pip install beautifulsoup4
  pip install lxml
  pip install cssselect
  ```

2. Insert your Discovery and Cloudant credentials into the `Scripts/.env` file.

  Name your Discovery collection and Cloudant database anything you prefer. If the Discovery collection or Cloudant database instance doesn't exist, the Python script will create them for you (assuming the credentials for each service was filled in correctly).

3. Run these two scripts in this order to load Cloudant and Discovery with information:

  ```bash
  python Scripts/ingest_reviews.py
  python Scripts/extract_upload_app_details.py
  ```
  The `ingest_reviews.py` script crawls reviews from the top 10 free apps by extracting reviews from the App Store's RSS feeds, then ingests the reviews into the Discovery service to enrich.

  The `extract_upload_app_details.py` script extracts general app detail information. This includes app name, description, URL, number of reviews, rating, etc. This information is then stored inside Cloudant to be called by the app.

### Setup Frontend Configuration

1. Install third-party dependencies using [Carthage](https://github.com/Carthage/Carthage). The first time you run this command can take  up to 20 minutes.

  ```bash
  cd app-insights-iOS
  cd carthage update --platform iOS
  ```

  This command pulls all dependencies from Carthage. We currently use the Graphs, Watson Developer Cloud's Swift SDK and SwiftyJSON libraries.

2. Insert your Discovery and Cloudant username and passwords into the `app-insights-iOS/app-insights/Credentials.swift`. Insert the same Discovery collection name and Cloudant database name you created when running the Python scripts into the Configuration file.   

### Running the project
Press build and run to see the app running in Xcode's iPhone simulator.
