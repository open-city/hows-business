var ChartHelper = {};
ChartHelper.renderToList = function(iteration, title, sourceTxt, yaxisLabel, data, startDate, pointInterval) {
  console.log("rendering to: #chart_list_" + iteration);
  console.log("title: " + title);
  console.log("sourceTxt: " + sourceTxt);
  console.log("yaxisLabel: " + yaxisLabel);
  console.log("data: " + data);
  console.log("startDate: " + startDate);
  console.log("pointInterval: " + pointInterval);
  var colorList = ["#4B0082", "#1F78B4", "#c30c30", "#33A02C", "#C09853", "#E31A1C", "#7C54FB", "#008000", "#6A3D9A", "#4B0082", "#1F78B4", "#c30c30", "#33A02C", "#C09853", "#E31A1C", "#7C54FB", "#008000", "#6A3D9A"];
  
  $("#charts").append("<div class='chart' id='chart_list_" + iteration + "'></div>")
  return new Highcharts.Chart({
      chart: {
          renderTo: "chart_list_" + iteration,
          type: 'line',
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
          text: "Source: " + sourceTxt,
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
            fillColor: colorList[iteration],
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
          color: colorList[iteration],
          data: data,
          showInLegend: false
      }]
    });
  }
  
ChartHelper.renderToGrouping = function(iteration, title, sourceTxt, yaxisLabel, dataArray, startDate, pointInterval) {
  console.log("rendering to: #chart_grouping_" + iteration);
  console.log("title: " + title);
  console.log("sourceTxt: " + sourceTxt);
  console.log("yaxisLabel: " + yaxisLabel);
  console.log("dataArray: " + dataArray);
  console.log("startDate: " + startDate);
  console.log("pointInterval: " + pointInterval);
  
  var colorList = ["#4B0082", "#1F78B4", "#c30c30", "#33A02C", "#C09853", "#E31A1C", "#7C54FB", "#008000", "#6A3D9A", "#4B0082", "#1F78B4", "#c30c30", "#33A02C", "#C09853", "#E31A1C", "#7C54FB", "#008000", "#6A3D9A"];
  
  $("#charts").append("<div class='chart' id='chart_grouping_" + iteration + "'></div>")
  return new Highcharts.Chart({
      chart: {
          renderTo: "chart_grouping_" + iteration,
          type: 'line',
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
          text: "Source: " + sourceTxt,
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
            fillColor: colorList[iteration],
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
            var s = "<strong>" + ChartHelper.toolTipDateFormat(pointInterval, this.x) + "</strong>";
            $.each(this.points, function(i, point) {
              s += "<br /><span style='color: " + point.series.color + "'>" + point.series.name + ":</span> " + Highcharts.numberFormat(point.y, 0);
            });
            return s;
          },
          shared: true
      },
      legend: {
        backgroundColor: "#ffffff",
        borderColor: "#cccccc",
        floating: true,
        verticalAlign: "top",
        x: 300,
        y: 60
      },
      series: [
        {
          color: "#4B0082",
          data: dataArray[0],
          name: "Raw numbers"
        }, {
          color: "#1F78B4",
          data: dataArray[1],
          name: "Seasonal trend"
        }
      ]
    });
  }

ChartHelper.pointInterval = function(interval) {
  if (interval == "year")
    return 365 * 24 * 3600 * 1000;
  if (interval == "quarter")
    return 3 * 30.4 * 24 * 3600 * 1000;
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
  if (interval == "quarter")
    return Highcharts.dateFormat("%B %Y", x);
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

