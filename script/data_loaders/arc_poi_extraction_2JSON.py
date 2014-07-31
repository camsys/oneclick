#!/usr/bin/env python

"""arc_poi_extraction.py"""
"""Given a map service url, for each layer, extract all features with geometry, save as json file for the layer"""
"""JSON data file path: ./data_{current_datetime_string}/{layer_name}.json"""
"""Parse each feature: loop features[], each feature element has attributes and geometry"""

import os
import urllib, urllib2
import json
from time import strftime

## get all leaf or non-grouped layers from a map service
def get_layerIds(mapserverUrl):
    layerInfos = []
    try:
        postData = urllib.urlencode({'f':'pjson'})
        response = json.load(urllib2.urlopen(mapserverUrl, postData))

        layers = response['layers']
        for layer in layers:
            subLayerIds = layer['subLayerIds']
            if subLayerIds == None or len(layer['subLayerIds']) == 0: #leaf layer
                layerInfos.append({
                    'id': layer['id'],
                    'name': layer['name']
                })
    except Exception, e:
        print 'something is wrong with getting map service layer info'
        print e

    return layerInfos

## given layer url, query all features, and save into a json file
def process_layer_query(param):
    try:
        url = param['url']
        postData = urllib.urlencode(param['postData'])
        saveFilePath = param['saveFilePath']
        response = json.load(urllib2.urlopen(url, postData)) 
        with open(saveFilePath, 'w') as f:
            json.dump(response, f)
        print 'done with ' + saveFilePath
    except Exception, e:
        print 'something is wrong with saving data to ' + saveFilePath
        print e
        
## main entry point
def main(mapServiceRootUrl):
    layers = get_layerIds(mapServiceRootUrl)

    folderName = 'data_' + strftime("%Y-%m-%d %H-%M-%S")
    if not os.path.exists(folderName):
        os.makedirs(folderName)
    
    params = []
    for layer in layers:
        params.append({
            'url': mapServiceRootUrl + '/' + str(layer['id']) + '/query',
            'postData': {
                'where': '1=1',
                'f': 'pjson',
                'returnGeometry': 'true',
                'outFields': '*'
                },
            'saveFilePath': folderName + '/' + str(layer['name']) + '.json'
            })
                             
    for param in params:
        process_layer_query(param)

    print 'All done.'

if __name__ == '__main__':
    mapServiceRootUrl = 'http://arcgis.atlantaregional.com/arcgis/rest/services/LifelongCommunities/MapServer'
    main(mapServiceRootUrl)
