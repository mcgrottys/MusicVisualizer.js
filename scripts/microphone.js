context = new (window.AudioContext || window.webkitAudioContext)();

navigator.getUserMedia = (navigator.getUserMedia ||
                          navigator.webkitGetUserMedia ||
                          navigator.mozGetUserMedia ||
                          navigator.msGetUserMedia);

//http://bl.ocks.org/pjanik/5169968
window.requestAnimationFrame = (function () {
    return window.requestAnimationFrame ||
           window.webkitRequestAnimationFrame ||
           window.mozRequestAnimationFrame ||
           window.oRequestAnimationFrame ||
           window.msRequestAnimationFrame ||
           function (callback, element) {
               return window.setTimeout(callback, 1000 / 60);
           };
})();

function MicrophoneSample() {
    this.getMicrophoneInput();
}

MicrophoneSample.prototype.getMicrophoneInput = function () {
    navigator.getUserMedia({ audio: true },
                            this.onStream.bind(this),
                            this.onStreamError.bind(this));
};

MicrophoneSample.prototype.onStream = function (stream) {
    var input = context.createMediaStreamSource(stream);

    var analyser = context.createAnalyser();
    analyser.minDecibels = -200;
    analyser.maxDecibels = -10;

    analyser.fftSize = 256;

    input.connect(analyser);

    this.analyser = analyser;
    NumOfBins = analyser.frequencyBinCount;


    line = d3.line()
             .curve(d3.curveBasis)
             .x(function (d, i) { return x(i); })
             .y(function (d) { return y(d); });

    hueScale = d3.scaleLinear()
               .domain([0, 256])
               .range([0, 512]);

    times = new Uint8Array(NumOfBins);

    x = d3.scaleLinear()
           .domain([0, times.length - 1])
           .range([0, width]);
    svg.selectAll(".bar").remove();


    bar = svg.selectAll(".bar")
        .data(times)
      .enter().append("g")
        .attr("class", "bar")
        .attr("transform", function (d, i) { return "translate(" + x(i) + "," + y(d + 4) + ")"; });

    bar.append("rect")
        .attr("class", "rect")
        .attr("x", 1)
        .attr("d", function (d) { return d; })
        .attr("width", x(1))
        .attr("height", function (d) { return height - y(d + 100); })
    .attr("fill", function (d, i) { return d3.hsl(hueScale(d), 1, 0.5) });

    requestAnimationFrame(this.visualize.bind(this));
};

MicrophoneSample.prototype.onStreamError = function (e) {
    console.error('Error getting microphone', e);
};


var margin = { top: 0, right: 0, bottom: 0, left: 0 },
    width = document.getElementById('visual').offsetWidth - margin.left - margin.right,
    height = document.getElementById('visual').offsetHeight - margin.top - margin.bottom;

var svg = d3.select("#visual").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform",
          "translate(" + margin.left + "," + margin.top + ")");

var y = d3.scaleLinear()
    .domain([0, 260])
    .range([height, 0]);

var NumOfBins = 200;

var synth = window.speechSynthesis;

var line = d3.line()
         .curve(d3.curveBasis)
         .x(function (d, i) { return x(i); })
         .y(function (d) { return y(d); });

var hueScale = d3.scaleLinear()
           .domain([0, NumOfBins - 1])
           .range([180, 240]);
var times = new Uint8Array(NumOfBins);

var x = d3.scaleLinear()
.domain([0, times.length - 1])
.range([0, width]);

var bar = svg.selectAll(".bar")
        .data(times)
      .enter().append("g")
        .attr("class", "bar")
        .attr("transform", function (d, i) { return "translate(" + x(i) + "," + y(d + 4) + ")"; });

MicrophoneSample.prototype.visualize = function () {

    this.analyser.getByteFrequencyData(times);

    svg.selectAll(".rect").remove();

    svg.selectAll(".bar").data(times)
        .attr("transform", function (d, i) { return "translate(" + x(i) + "," + y(d + 4) + ")"; });

    bar.append("rect")
        .attr("class", "rect")
        .attr("x", 1)
        .attr("d", function (d) { return d; })
        .attr("width", x(1))
        .attr("height", function (d) { return height - y(d + 100); })
    .attr("fill", function (d, i) { return d3.hsl(hueScale(d), 1, 0.5) });

    requestAnimationFrame(this.visualize.bind(this));
};
