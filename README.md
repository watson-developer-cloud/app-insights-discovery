# app-insights-discovery

Requirements:

- Bluemix account
- Cloudant account
- Discovery Service Instance
- Xcode 8.x, Swift 3.x

![Preview](images/App_Insights_Preview.gif)

##Overview
All back-end set up will be run through the `ingest_reviews.py` and `extract_upload_app_details.py` scripts:

- Grab top 100 free apps from the App Store
- Extract the App Store's reviews about the apps
- Upload each review as a document to the Discovery service

### Setting up Backend
Install the following Python libraries:

```bash
pip install --upgrade watson-developer-cloud
pip install -U python-dotenv
pip install beautifulsoup4
```

Insert your Discovery and Cloudant credentials into the `Scripts/.env` file. 

Run the following:

```bash
python Scripts/ingest_reviews.py
python Scripts/extract_upload_app_details.py
```
The `ingest_reviews.py` script crawls reviews from the top 10 free apps by extracting reviews from the App Store's RSS feeds, then ingests the reviews into the Discovery service to enrich. 

The `extract_upload_app_details.py` script extracts general app detail information. This includes app name, description, URL, number of reviews, rating, etc. This information is then stored inside Cloudant to be called by the app. 


### Setting up xcodeproj
Within the `app-insights-iOS` directory, run the following:
`carthage update`

This command pulls all dependencies from Carthage. We currently use the Graphs, Watson Developer Cloud's Swift SDK and SwiftyJSON libraries. 

Insert your Discovery and Cloudant username and passwords into the `app-insights-iOS/app-insights/Configuration.swift`.

### Running the project
Press build and run to see the app running in Xcode's iPhone simulator. 



