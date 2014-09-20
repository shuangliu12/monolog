var fill = d3.scale.category20();

    d3.layout.cloud().size([550, 550])
      .words(['Freezing', 'cold', 'unpleasant', 'conversation', 'mom', 'Called', 'talked', 'leave', 'Stop', 'Shop', 'food', 'water', 'chips', 'dip', 'watched', 'comedy', 'show', 'show', 'boring', 'replied', 'email', 'made', 'hotpot', 'sauce', 'time', 'taste', 'added', 'salt', 'vinegar', 'taste', 'good', 'eat', 'understand', 'hotpot', 'boring', 'text', 'message', 'texted', 'back', 'told', 'missed', 'played', 'games', 'lost', 'interests', 'games', 'watched', 'shows', 'shows', 'working', 'writing', 'chapter', 'long', 'Saturday', 'met', 'started', 'Saturdays', 'met', 'missed', 'Playing', 'games', 'fun', 'strange', 'fun', 'activity', 'Reading', 'email', 'makes', 'sad', 'Shhh', 'learn', '5words', 'time', 'today', 'kind', 'back', 'home', 'home', 'China', 'back', 'H1B', 'back', 'make', 'cry', 'work', 'job', 'month', 'check', 'flight', 'ticket', 'thinking', 'China', 'long', 'killed', 'pollution', 'totally', 'excited', 'facial', 'expression', 'make', 'poker', 'face', 'thinking', 'Karatsuba', 'Multiplication', 'program', 'loop', 'recursive', 'watching', 'Ipartment', 'hilarious', 'tricking', 'Japanese', 'guy', 'Yep', 'def', 'watch', 'episode', 'people', 'trick', 'foreigners'].map(function(d) {
        return {text: d, size: 10 + Math.random() * 90};
      }))
      .padding(5)
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font("Impact")
      .fontSize(function(d) { return d.size; })
      .on("end", draw)
      .start();

    function draw(words) {
    d3.select("body").append("svg")
        .attr("width", 550)
        .attr("height", 550)
      .append("g")
        .attr("transform", "translate(275,275)")
      .selectAll("text")
        .data(words)
      .enter().append("text")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("font-family", "Impact")
        .style("fill", function(d, i) { return fill(i); })
        .attr("text-anchor", "middle")
        .attr("transform", function(d) {
          return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
    }
