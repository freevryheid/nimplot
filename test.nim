import
  random
  , algorithm
  , sequtils
  , plot

proc main() =
  var
    scatter = newScatter()
    ds1 = scatter.newDataSet()
    ds2 = scatter.newDataSet()
    ds3 = scatter.newDataSet()
    x, y1, y2, y3: seq[float]

  x = toSeq(0..99).map(proc(z: int): float = float(z))
  ds1.x = x
  ds2.x = x
  ds3.x = x
  y1 = x.map(proc(z: float): float = rand(25.0))
  y2 = x.map(proc(z: float): float = rand(50.0))
  y3 = x.map(proc(z: float): float = rand(100.0))
  ds1.y = y1
  ds2.y = y2
  ds3.y = y3

  scatter.series.add(ds1)
  scatter.series.add(ds2)
  scatter.series.add(ds3)
  scatter.plot().writePNG("test.png")

when isMainModule:
  main()
