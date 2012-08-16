var ChartHelper = {};
ChartHelper.create = function(renderTo, title, sourceTxt, yaxisLabel, fillColor, data, startDate, pointInterval) {
  return new Highcharts.Chart({
      chart: {
          renderTo: renderTo,
          type: 'spline',
          marginRight: 130,
          marginBottom: 25
      },
      legend: { 
        enabled: false 
      },
      credits: { 
        enabled: false 
      },
      title: {
          text: title,
          x: -20 //center
      },
      subtitle: {
          text: sourceTxt,
          x: -20
      },
      xAxis: {
          dateTimeLabelFormats: { year: "%Y" },
          type: "datetime"
      },
      yAxis: {
          title: {
              text: yaxisLabel
          }
      },
      plotOptions: {
        series: {
          lineWidth: 2,
          marker: {
            fillColor: fillColor,
            radius: 0,
            states: {
              hover: {
                enabled: true,
                radius: 5
              }
            }
          },
          pointInterval: ChartHelper.pointInterval(pointInterval),  
          pointStart: startDate,
          shadow: false,
          states: {
             hover: {
                lineWidth: 2
             }
          }
        }
      },
      tooltip: {
          crosshairs: true,
          formatter: function() {
            return "<strong>" + ChartHelper.toolTipDateFormat(pointInterval, this.x) + "</strong><br/>" + yaxisLabel + ": " + this.y;
          }
      },
      legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'top',
          x: -10,
          y: 100,
          borderWidth: 0
      },
      series: [{
          color: fillColor,
          data: data,
          showInLegend: false
      }]
    });
  }
  
ChartHelper.pointInterval = function(interval) {
  if (interval == "year")
    return 365 * 24 * 3600 * 1000;
  if (interval == "month") //this is very hacky. months have different day counts, so our point interval is the average - 30.4
    return 30.4 * 24 * 3600 * 1000;
  if (interval == "week")
    return 7 * 24 * 3600 * 1000;
  if (interval == "day")
    return 24 * 3600 * 1000;
  if (interval == "hour")
    return 3600 * 1000;
  else
    return 1;
}

ChartHelper.toolTipDateFormat = function(interval, x) {
  if (interval == "year")
    return Highcharts.dateFormat("%Y", x);
  if (interval == "month")
    return Highcharts.dateFormat("%B %Y", x);
  if (interval == "week")
    return Highcharts.dateFormat("%e %b %Y", x);
  if (interval == "day")
    return Highcharts.dateFormat("%e %b %Y", x);
  if (interval == "hour")
    return Highcharts.dateFormat("%H:00", x);
  else
    return 1;
}

