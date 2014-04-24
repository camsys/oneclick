#!/usr/bin/env python

"""arc_poi_extraction.py"""
"""Given a map service url, for each layer, extract all features with geometry, save as CSV file for the layer"""
"""CSV data file path: ./data_{current_datetime_string}/{layer_name}.csv"""

import os
import urllib, urllib2
import json, csv
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
def process_layer_query(param, fieldMapping):
    try:
        url = param['url']
        postData = urllib.urlencode(param['postData'])
        saveFilePath = param['saveFilePath']
        response = json.load(urllib2.urlopen(url, postData))

        #check if has 'features' key
        if not response.has_key('features'):
            print 'no features from response to save into ' + saveFilePath
            return

        features = response['features']
        if not isinstance(features, list) or not features:
            print 'empty data to save into ' + saveFilePath
            return

        headerRowNames = []
        for field in fieldMapping:
            headerRowNames.append(field['OutputName'])
        
        f = csv.writer(open(saveFilePath, 'wb'))
        f.writerow(headerRowNames)
        for feat in features:
            attrs = feat['attributes']
            geom = feat['geometry']
            valList = []
            for field in fieldMapping:
                fieldName = field['SourceFieldName']
                if attrs.has_key(fieldName): # in attributes?
                    valList.append(attrs[fieldName])
                elif geom.has_key(fieldName): # in geometry?
                    valList.append(geom[fieldName])
                else: # assign empty
                    valList.append("")
            f.writerow(valList)
                
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
                'outFields': '*',
                'outSR': '4326'
                },
            'saveFilePath': folderName + '/' + str(layer['name']) + '.csv'
            })

    # All layers in this map service have same fields, so can use one config
    # otherwise, need to have each mapping for each layer
    fieldMapping = [
        {
            "OutputName": "OBJECTID",
            "SourceFieldName": "OBJECTID"
        },
        {
            "OutputName": "LONGITUDE",
            "SourceFieldName": "y"
        },
        {
            "OutputName": "LATITUDE",
            "SourceFieldName": "x"
        },
        {
            "OutputName": "POI_NAME",
            "SourceFieldName": "OrgName"
        },
        {
            "OutputName": "Address_1",
            "SourceFieldName": "LocAddress"
        },
        {
            "OutputName": "Address_2",
            "SourceFieldName": ""
        },
        {
            "OutputName": "CITY",
            "SourceFieldName": "LocCity"
        },
        {
            "OutputName": "STATE",
            "SourceFieldName": "LocState"
        },
        {
            "OutputName": "ZIP",
            "SourceFieldName": "LocZipCode"
        },
        {
            "OutputName": "RESERVED_1",
            "SourceFieldName": ""
        },
        {
            "OutputName": "RESERVED_2",
            "SourceFieldName": ""
        },
        {
            "OutputName": "RESERVED_3",
            "SourceFieldName": ""
        },
        {
            "OutputName": "COUNTY",
            "SourceFieldName": "County"
        },
        {
            "OutputName": "POI_TYPE",
            "SourceFieldName": "ServiceDes"
        }
    ]
    
    for param in params:
        process_layer_query(param, fieldMapping)

    print 'All done.'

if __name__ == '__main__':
    mapServiceRootUrl = 'http://arcgis.atlantaregional.com/arcgis/rest/services/LifelongCommunities/MapServer'
    main(mapServiceRootUrl)
