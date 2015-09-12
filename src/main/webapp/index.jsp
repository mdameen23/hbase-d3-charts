<html>
    <head>
        <meta charset="utf-8">
        <style>
        .graph .axis { stroke-width: 1; }
        .graph .axis .tick line { stroke: black; }
        .graph .axis .tick text { fill: black; font-size: 0.7em; }
        .graph .axis .domain { fill: none; stroke: black; }
        .legend-text { font-size: 0.8em; }
        .chartArea { border: 4px solid gray; background-color: white; }
        .graph .group { fill: none; stroke: black; stroke-width: 1.5; }
        </style>
        <script type="text/javascript" src="script/d3.min.js"></script>
        <script type="text/javascript" src="script/jquery.min.js"></script>
        <script>
        var limit = 60;
        var duration = 2000;
        var now = new Date(Date.now() - duration);
        var margin = {top: 20, right: 0, bottom: 50, left: 0};
        var width = 500 - margin.left - margin.right;
        var height = 300 - margin.top - margin.bottom;

        var groupNames = [ ];
        var dataGroups = { };
        var groupColors = {
            0: "#872657",
            1: "#6959CD",
            2: "#308014",
            3: "#8B5A00",
            4: "#EE6363",
            5: "#33A1C9",
            6: "#B23AEE",
            7: "#54FF9F",
            8: "#CDC673",
            9: "#FFA500"
        };

        var xScale = d3.time.scale()
                            .domain([now - (limit - 2), now - duration])
                            .range([0, width]);

        var yScale = d3.scale.linear()
                       .domain([0, 100])
                       .range([height, 0]);

        var lineFunc = d3.svg.line()
                             .interpolate("basis")
                             .x(function(d, i) {  return xScale(now - (limit - 1 - i) * duration) })
                             .y(function(d) { return yScale(d) });

        var xBarScale;
        var barWidth;
        var chartArea;
        var xAxisElem;
        var paths;
        var legend;
        var barChart;
        var firstLoad = true;

        function init() {
            xBarScale = d3.scale.ordinal()
                          .domain(groupNames)
                          .rangeBands([0, width]);

            barWidth = width / groupNames.length;

            chartArea = d3.select(".graph")
                          .append("svg")
                          .attr("width", width + margin.left + margin.right)
                          .attr("height", height + margin.top + margin.bottom)
                          .attr("class" , "chartArea")
                          .append("g")
                          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");;

            xAxisElem = chartArea.append("g")
                                 .attr("class", "x axis")
                                 .attr("transform", "translate(0," + height + ")")
                                 .call(xScale.axis = d3.svg.axis().scale(xScale).orient("bottom"));

            barChart = d3.select(".graph")
                         .append("svg")
                         .attr("width", width + margin.left + margin.right)
                         .attr("height", height + margin.top + margin.bottom)
                         .attr("class" , "chartArea")
                         .append("g")
                         .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            var bar = barChart.selectAll("g")
                           .data(groupNames)
                           .enter().append("g")
                           .attr("transform", function(d, i) { return "translate(" + i * barWidth + ",0)"; });

            bar.append("rect")
               .attr("y", function(d) { return yScale(dataGroups[d].value); })
               .attr("height", function(d) { return height - yScale(dataGroups[d].value); })
               .attr("width", barWidth - 1)
               .attr("style:fill", function(d, i) { return groupColors[i] });

            barChart.append("g")
                 .attr("class", "x axis")
                 .attr("transform", "translate(0," + height + ")")
                 .call(d3.svg.axis().scale(xBarScale).orient("bottom"));

            paths = chartArea.append("g");
            legend = chartArea.append("g");

            legend.append("text")
                  .text("")
                  .attr("class", "legend-text")
                  .attr("y", height + 40);

            var leftPos = 20;
            var count = 0;
            for (var name in dataGroups) {
                var group = dataGroups[name];
                group.path = paths.append('path')
                     .data([group.data])
                     .attr("class", name + " group")
                     .style("stroke", groupColors[count]);

                legend.append("text")
                      .attr("y", height + 40)
                      .attr("x", leftPos)
                      .attr("id", "legend-" + name)
                      .attr("class", "legend-text")
                      .attr("fill", groupColors[count])
                      .text(name);
                leftPos += 70;
                count++;
            }

            tick();
        }

        function tick() {
            now = new Date();
            queryHbase();

            for (var name in dataGroups) {
                var group = dataGroups[name];
                var newVal = group.value;
                group.data.push(newVal);
                group.path.attr('d', lineFunc);
                chartArea.select("#legend-" + name)
                         .text(name + ": " + newVal);
            }

            xScale.domain([now - (limit - 2) * duration, now - duration]);

            xAxisElem.transition()
                     .duration(duration)
                     .ease('linear')
                     .call(xScale.axis);

            paths.attr('transform', null)
                 .transition()
                 .duration(duration)
                 .ease('linear')
                 .attr('transform', 'translate(' + xScale(now - (limit - 1) * duration) + ')')
                 .each('end', tick);

            barChart.selectAll("rect")
                 .data(groupNames)
                 .transition()
                 .duration(1000)
                 .attr("y", function(d) { return yScale(dataGroups[d].value); })
                 .attr("height", function(d) { return height - yScale(dataGroups[d].value); });

            for (var name in dataGroups) {
                var group = dataGroups[name];
                group.data.shift();
            }
        }


        function queryHbase() {
            var queryURL = "QueryHBase?tName=channel_views&cfName=views&cName=total_views";

            $.ajax({
                url: queryURL,
                dataType: "json",
                type: "GET"
            }).done( function(data) {
                for (var dKey in data) {
                    var dValue = data[dKey];

                    if (groupNames.indexOf(dKey) == -1) {
                        groupNames.push(dKey);
                        dataGroups[dKey] = {key: dKey };

                        dataGroups[dKey].value = dValue;
                        dataGroups[dKey].data = d3.range(limit).map(function() { return 0});
                    } else {
                        dataGroups[dKey].value = dValue;
                    }
                }

                if (firstLoad) {
                    init();
                    firstLoad = false;
                }
            });
        }
        </script>
    </head>
    <body onload="queryHbase()">
        <div class="graph"></div>
        <br>
        <div id="data"></div>
    </body>
</html>
