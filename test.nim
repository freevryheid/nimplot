import
  random
  , plot

proc genSeries(): Series =
  result = @[]
  for i in 0..3:
    var
      s: Serie
      P: Points
    s.legend = "S" & $i
    P = @[]
    for j in 0..10:
      var p: Point
      p.x = rand(100.0)
      p.y = rand(100.0)
      P.add(p)
    s.data = P
    result.add(s)

proc main() =
  var
    series = genSeries()
    scatter = newScatter()

  scatter.series = series
  scatter.plot().writePNG("test.png")

when isMainModule:
  main()
