from lxml.cssselect import CSSSelector
import lxml.html
import requests
import re

## Extract name and ID from top 100 free apps
id_finder = re.compile('\/id([0-9]+)')

def extract_id(linkstr):
    """ Extract and return app ID from the webpage using XML CSSSelector.
    """
    mid = id_finder.search(linkstr)
    if mid:
        return mid.group(1)
    else:
        return "not found"

def grab_top_apps():
    """ Grap the top 100 apps featured in the free-apps iTunes chart.
        Returns a dictionary that contains a list of dictionary objects per app.
        Dictionary object contains app ID, app title and app URL.
    """
    r = requests.get('http://www.apple.com/itunes/charts/free-apps/')
    # Convert page into an xml string to parse.
    tree = lxml.html.fromstring(r.text)
    # Select all children that contains these HTML tags.
    sel = CSSSelector('div.section-content ul li h3 a')
    results = sel(tree)
    # From the selected children grab the <href> tag and text.
    return {'result' : [{"id": extract_id(x.get('href')), "title": x.text, "url": x.get('href')}
                        for x in
                        results]}
