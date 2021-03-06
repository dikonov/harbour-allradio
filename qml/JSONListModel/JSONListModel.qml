/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "../js/jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string sortby: ""
    property string filterby: ""
    property string filterkey: ""
    property bool get: true
    property bool ready: false

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        ready = false
        //console.log(useragent)
        var xhr = new XMLHttpRequest;
        xhr.open(get ? "GET" : "POST", source);
        xhr.setRequestHeader('User-Agent',useragent);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200)
                json = xhr.responseText;
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()
    onFilterbyChanged: updateJSONModel()
    onFilterkeyChanged: updateJSONModel()
    onSortbyChanged: updateJSONModel()

    function updateJSONModel() {
        jsonModel.clear();

        if ( json === "" )
            return;

        var objectArray = parseJSONString(json, query);

        if (sortby !== "") objectArray = sortByKey(objectArray, sortby);
        if (filterby !== "" && filterkey !=="") objectArray = filterValuePart(objectArray, filterby, filterkey);

        for ( var key in objectArray ) {
            var jo = objectArray[key];
            jsonModel.append( jo );
        }
        ready = true
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }

    function filterValuePart(array, part, key) {
        part = part.toLowerCase();
        return array.filter(function(a) {
            var x = a[key];
            return x.toLowerCase().indexOf(part) !== -1;
        });
    }

    function sortByKey(array, key) {
        return array.sort(function(a, b) {
            var x = a[key]; var y = b[key];
            return ((x > y) ? -1 : ((x < y) ? 1 : 0));
        });
    }
}
