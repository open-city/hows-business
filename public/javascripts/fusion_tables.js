/*!
 * Google Fusion Tables Wrapper
 * Copyright 2012, Derek Eder
 */
 
var FusionTables = FusionTables || {};
var FusionTables = {
  
  //Setup section - put your Fusion Table details here
  //Using the v1 Fusion Tables API. See https://developers.google.com/fusiontables/docs/v1/migration_guide for more info
  
  //the encrypted Table ID of your Fusion Table (found under File => About)
  //NOTE: numeric IDs will be depricated soon
  fusionTableId:      "1_RnACjjyI4qmAaOQyRFB2W5iItGnvbqNaymnEW4",  
  
  //*New Fusion Tables Requirement* API key. found at https://code.google.com/apis/console/      
  googleApiKey:       "AIzaSyAcsnDc7_YZskPj4ep3jT_fkpB3HI_1a98",        
  
  query: function(selectColumns, whereClause, orderBy, callback) {
    var queryStr = [];
    queryStr.push("SELECT " + selectColumns);
    queryStr.push(" FROM " + FusionTables.fusionTableId);
    
    if (whereClause != "")
      queryStr.push(" WHERE " + whereClause);

    if (orderBy != "")
      queryStr.push(" ORDER BY " + orderBy);
  
    var sql = encodeURIComponent(queryStr.join(" "));
    //console.log("https://www.googleapis.com/fusiontables/v1/query?sql="+sql+"&callback="+callback+"&key="+FusionTables.googleApiKey);
    $.ajax({url: "https://www.googleapis.com/fusiontables/v1/query?sql="+sql+"&callback="+callback+"&key="+FusionTables.googleApiKey, dataType: "jsonp"});
  },

  //converts a text in to a URL slug
  convertToSlug: function(text) {
    if (text == undefined) return '';
    return (text+'').replace(/ /g,'-').replace(/[^\w-]+/g,'');
  },
  
  getChartList: function(whereClause) {
    var selectColumns = "*";
    FusionTables.query(selectColumns, whereClause, "", "FusionTables.displayChartList");
  },
  
  displayChartList: function(json) {
    data = json["rows"]; 
    //console.log(data.length);
    for (var i = 0; i < data.length; i++) {
        var row = data[i];
        var rowData = row[6].split(",");
        for(var j=0; j<rowData.length; j++) { 
          if (rowData[j] == 0)
            rowData[j] = null
          else
            rowData[j] = +rowData[j]; 
        } 
        //console.log(rowData);
        //title, sourceTxt, yaxisLabel, data, startDate, pointInterval
        ChartHelper.create(FusionTables.convertToSlug(row[0]), row[3], row[4], row[5], [rowData], Date.UTC(row[7], 0, 28), row[8]);
    }
  },

  getChartGrouping: function(whereClause) {
    var selectColumns = "*";
    FusionTables.query(selectColumns, whereClause, "Type", "FusionTables.displayChartGrouping");
  },
  
  displayChartGrouping: function(json) {
    data = json["rows"]; 
    var dataArray = [];
    for (var i = 0; i < data.length; i++) {
        var row = data[i];
        var rowData = row[6].split(",");
        for(var j=0; j<rowData.length; j++) { 
          if (rowData[j] == 0)
            rowData[j] = null
          else
            rowData[j] = +rowData[j]; 
        }
        dataArray[i] = rowData;
    }
    //iteration, title, sourceTxt, yaxisLabel, dataArray, startDate, pointInterval
    ChartHelper.create(FusionTables.convertToSlug(row[0]), row[3], row[4], row[5], dataArray, Date.UTC(row[7], 0, 28), row[8]);
  }
}