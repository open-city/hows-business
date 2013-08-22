$(function () {
  showChart(licenses);
  showChart(unemployment);
  showChart(permits);
  showChart(foreclosures);
});

function showChart(json) {
	var raw = json['Data Raw'];
	var trend = json['Data Trend'];

	// ensure null values instead of missing for data arrays
	for (var i = 0; i < raw.length; i++)
		if (raw[i] == undefined) raw[i] = null;
	for (var i = 0; i < trend.length; i++)
		if (trend[i] == undefined) trend[i] = null;

	var startDate = Date.UTC(json['Start Year'], 0, 28);
	if (json['Point Interval'] == 'quarter')
	  startDate = Date.UTC(json['Start Year'], 0, 15);

	//iteration, title, sourceTxt, yaxisLabel, dataArray, startDate, pointInterval
	ChartHelper.create(convertToSlug(json['grouping']), json['Title'], json['Source'], json['Label'], [raw, trend], startDate, json['Point Interval']);

}

function convertToSlug(text) {
    if (text == undefined) return '';
    return (text+'').replace(/ /g,'-').replace(/[^\w-]+/g,'');
 }