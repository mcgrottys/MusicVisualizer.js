<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <script src="scripts/jquery-3.1.1.js"></script>
    <%--<script src="scripts/d3.v3.min.js"></script>--%>
    <script src="scripts/d3.js"></script>
    <title></title>
    <style>
        a {
            color: white;
        }

        .line {
            fill: none;
            stroke-width: 1.5px;
        }

        body {
            color: white;
            font-family: monospace;
            line-height: 1.5;
            background-color: #130C0E;
            padding: 20px;
        }

        button {
            font-size: 14px;
            background: #130C0E;
            color: #7AC143;
            border: none;
            outline: none;
            padding: 4px 8px;
            letter-spacing: 1px;
        }

            button:hover {
                background: #7AC143;
                color: #130C0E;
            }
    </style>
</head>
<body>

    <div>
        To play your own Mp3 <input id="audio_file" type="file" accept="audio/*" />

        Number of frequency lines <input type="range" id="FreqRange" min="1" max="200" value="20" />

        Horizontal Value Range  <input type="range" id="CountRange" value="100" min="5" max="1000" />
        <br />
        <a href="http://www.wethepopulace.com/">Listen to more tracks like this at http://www.wethepopulace.com/</a>
        <br />
        To start the visualizer press play
        <audio controls="controls" id="audioElement" src="The One Live June 2016_278813151_soundcloud.mp3" />

    </div>


</body>

<script>
        audio_file.onchange = function () {
            var files = this.files;
            var file = URL.createObjectURL(files[0]);
            audioElement.src = file;
            //audioElement.play();
        };

        var FreqSize = FreqSize = $('#FreqRange').val();
        var frequencyData = new Uint8Array(FreqSize);
        var Count = Count = $('#CountRange').val();
        var AllSeries = [];
        for (i = 0; i < FreqSize; i++) {
            AllSeries.push(new Array(Count).fill(0));
        }

        

        function GetFreqArray(index,arr)
        {
            var ret = [];

            for(var z = 0; z< arr.length; z++)
            {
                ret.push(arr[z][index]);
            }
            return ret;
        }

        (function () {

            $('#FreqRange').change(function (d) {
                FreqSize = $('#FreqRange').val();
                AllSeries = [];
                for (i = 0; i < FreqSize; i++) {
                    AllSeries.push(new Array(Count).fill(0));
                }
                frequencyData = new Uint8Array(FreqSize);

                g.selectAll(".frequency").remove();

                var Series = g.selectAll(".frequency")
   .data(AllSeries)
   .enter().append("g")
   .attr("class", "frequency");



                Series.append("path")
                               .attr("class", "line")
                               .attr("d", line)
                     .style("stroke", function (d, i) { return d3.hsl(hueScale(i), 1, 0.5); });
                


                hueScale = d3.scaleLinear()
              .domain([0, AllSeries.length])
              .range([0, 360]);
            })

            $('#CountRange').change(function (d) {
                Count = $('#CountRange').val();
            })


            'use strict';

            var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            var audioElement = document.getElementById('audioElement');
            var audioSrc = audioCtx.createMediaElementSource(audioElement);
            var analyser = audioCtx.createAnalyser();

            // bind our analyser to the media element source.
            audioSrc.connect(analyser);
            audioSrc.connect(audioCtx.destination);

            var truemax = 10;

            var svgHeight = 800,
                svgWidth = 1800;

            // set the dimensions and margins of the graph
            var margin = { top: 20, right: 150, bottom: 30, left: 50 },
                width = 1800 - margin.left - margin.right,
                height = 800 - margin.top - margin.bottom;


            // append the svg obgect to the body of the page
            // appends a 'group' element to 'svg'
            // moves the 'group' element to the top left margin
            var svg = d3.select("body").append("svg")
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
              .append("g")
                .attr("transform",
                      "translate(" + margin.left + "," + margin.top + ")");
            var g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

            var y = d3.scaleLinear()
                .domain([0, 255])
                .range([height, 0]);

          

            var x = d3.scaleLinear()
.domain([0, AllSeries[0].length])
.range([0, width]);

            var hueScale = d3.scaleLinear()
               .domain([0, AllSeries.length])
               .range([0, 360]);


            var vline = d3.line()
                .curve(d3.curveCatmullRomOpen)
                .x(function (d, i) {
                    return x(i);
                })
                .y(function (d) {
                    return y(d);
                });

            var line = d3.line()
                .curve(d3.curveBasis)
                .x(function (d,i) { return x(i); })
                .y(function (d) { return y(d); });
       
            var Series = g.selectAll(".frequency")
    .data(AllSeries)
    .enter().append("g")
    .attr("class", "frequency");



            Series.append("path")
                           .attr("class", "line")
                           .attr("d", line)
                 .style("stroke", function (d, i) { return d3.hsl(hueScale(i), 1, 0.5); });
           
            var moveleft = -1;

            function renderChart() {

                setTimeout(renderChart, 10);

                analyser.getByteFrequencyData(frequencyData);

                AllSeries.forEach(function (d, i) {

                    d.push(parseInt(frequencyData[i]));
                });
             
                x.domain([0, AllSeries[0].length]);

                svg.selectAll("path")
                      .attr("d", line)
      .attr("transform", null);

                svg.selectAll("path")
                .attr("transform", "translate(" + x(moveleft) + ",0)")
    .transition();
                AllSeries.forEach(function (d, i) {
                    if (d.length > Count) {
                        d.shift();
                        d.shift();
                        moveleft = -2;
                    }
                    else if (d.length >= Count) {
                        d.shift();
                        moveleft = -1;
                    }
                    else {
                        moveleft = 0;
                    }
                });

            }


            renderChart();


        }());

</script>
</html>