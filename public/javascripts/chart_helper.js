var ChartHelper = {};
ChartHelper.create = function(renderTo, title, yaxis, fillColor, data) {
  return new Highcharts.Chart({
      chart: {
          renderTo: renderTo,
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
          text: 'Source: City of Chicago',
          x: -20
      },
      xAxis: {
          dateTimeLabelFormats: { year: "%Y" },
          type: "datetime"
      },
      yAxis: {
          title: {
              text: yaxis
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
          //this is very hacky. months have different day counts, so our point interval is the average - 30.4
          pointInterval: 30.4 * 24 * 3600 * 1000,  
          pointStart: Date.UTC(2005, 0, 28), //give ourselves a little buffer to fudge the month intervals
          shadow: false,
          states: {
             hover: {
                lineWidth: 2
             }
          }
        }
      },
      tooltip: {
          formatter: function() {
            return "<strong>" + Highcharts.dateFormat("%B %Y", this.x) + "</strong><br/>"+this.y;
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