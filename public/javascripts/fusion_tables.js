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
  
  query: function(selectColumns, whereClause, callback) {
    var queryStr = [];
    queryStr.push("SELECT " + selectColumns);
    queryStr.push(" FROM " + FusionTables.fusionTableId);
    
    if (whereClause != "")
      queryStr.push(" WHERE " + whereClause);
  
    var sql = encodeURIComponent(queryStr.join(" "));
    console.log("https://www.googleapis.com/fusiontables/v1/query?sql="+sql+"&callback="+callback+"&key="+FusionTables.googleApiKey);
    $.ajax({url: "https://www.googleapis.com/fusiontables/v1/query?sql="+sql+"&callback="+callback+"&key="+FusionTables.googleApiKey, dataType: "jsonp"});
  },
  
  getChartData: function() {
    var selectColumns = "*";
    FusionTables.query(selectColumns, "","FusionTables.displayChartData");
  },
  
  displayChartData: function(json) {
    data = json["rows"]; 
    console.log(data.length);
    for (var i = 0; i < data.length; i++) {
        var row = data[i];
        var rowData = row[6].split(",");
        for(var j=0; j<rowData.length; j++) { rowData[j] = +rowData[j]; } 
        //console.log(rowData);
        //renderTo, title, sourceTxt, yaxisLabel, fillColor, data, startDate, pointInterval
        ChartHelper.create(row[1], row[2], row[3], row[4], row[5], rowData, Date.UTC(row[7], 0, 28), row[8]);
    }
  }
}