angular.module('BWProgress', [])
  .directive('progressIndicator', ($parse)->
    return {
      restrict: 'E'
      scope:
        expected: "="
        actual: "="
      link: (scope, element, attr) ->

        scope.$watchCollection '[expected, actual]', ([expected, actual]) ->
          if isValid(expected, actual)
            svg.selectAll("*").remove()
            drawProgressIndicator(expected, actual)
          #TODO show message

        svg = d3.select(element[0]).append('svg')

        isValid = (expected, actual)->
          if expected is undefined or actual is undefined or
            isNaN(expected) or isNaN(actual) or
            expected < 0 or expected > 1 or
            actual < 0 or actual > 1
              return false
          return true

        drawProgressIndicator = (expected, actual) ->
          percentage = Math.round(actual/expected * 100)

          elem = svg.append("g")
            .attr("class", "circle-translate")

          #inner circle
          elem.append("circle")
            .attr("r", 80)

          progressNum = elem.append("text")
            .attr("class", "progress-num")
            .attr("dx", -40)
            .attr("dy", 15)
            .attr("textLength", "80px")
            .text(percentage)

          progressNum.append("tspan")
            .text("%")

          elem.append("text")
            .attr("class", "progress-text")
            .attr("dx", -35)
            .attr("dy", 40)
            .attr("textLength", "80px")
            .text('Progress')

          arcs = [
            {
              id: "actual-arc"
              class: "circle-translate"
              innerRadius: 90,
              outerRadius: 93,
              endAngle: parseFloat(actual)
            },
            {
              id: "expected-arc"
              class: "circle-translate"
              innerRadius: 95,
              outerRadius: 100,
              endAngle: parseFloat(expected)
            }
          ]

          color = d3.scale.linear().domain([0, 60, 100]).range(["#D91500","#FFBA00", "#60CC00"])

          svg.selectAll("path.arc").data(arcs)
            .enter().append("path")
            .attr("id", (d) -> d.id)
            .attr("class", (d) -> d.class)
            .transition().duration(800)
            .attrTween("d", (d) ->
              return d3.svg.arc()
                .innerRadius(d.innerRadius)
                .outerRadius(d.outerRadius)
                .startAngle(0)
                .endAngle((t) -> t * (d.endAngle/1) * 2 * Math.PI)
            ).attr('fill', color(percentage))

    }
  )

angular.module 'BWApp', ['BWProgress']
