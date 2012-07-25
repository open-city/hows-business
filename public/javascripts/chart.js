$(function () {
  var chart;
  $(document).ready(function() {
    chart = new Highcharts.Chart({
      chart: {
          renderTo: 'container',
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
          text: 'Seasonally adjusted trend of issued business licenses',
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
              text: 'Issued business licenses'
          },
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
          }]
      },
      plotOptions: {
        series: {
          lineWidth: 2,
          marker: {
            fillColor: "#518fc9",
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
                  return '<b>'+ this.series.name +'</b><br/>'+
                  this.y;
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
          name: 'Issued licenses',
          data: [925.87,934.2,942.87,951.83,962.26,971.41,973.31,962.89,938.15,908.63,882.26,867,867.25,877.69,892.67,903.1,898.88,891.82,887.82,889.04,912.05,939.25,965.54,988.44,955.04,905.64,869.84,826.66,788.85,784.73,786.61,794.83,819.96,854.63,887.01,915,930.63,928.1,910.7,890.14,868.53,844.33,824.96,806.56,780.27,754.26,732.28,711.82,697.44,694.79,703.38,719.42,745.04,766.8,771.47,774.57,777.5,774.72,765.08,753.41,741.07,725.17,709.31,699,686.48,676.76,673.78,674.42,678.14,691.31,708.69,724.47,744.93,761.5,761.7,767.09,772.42,771.68,774.11,774.24,767.09,753.18,738.69,724.93,708.81,695.03,684.13,670.79,657.74,645.09]
      }]
    });
  });  
});