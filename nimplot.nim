import
  sequtils
  , random
  , sdl2

var
  w:cint = 640
  h:cint = 480

randomize()

iterator rnds(n: int): float =
  for i in 0..n-1:
    yield rand(-1.0..1.0)

proc genPoints(x, y: seq[float]): seq[Point] =
  result = @[]
  var
    xmin = min(x)
    xmax = max(x)
    ymin = min(y)
    ymax = max(y)
  for i in 0..len(x)-1:
    var p:Point = (cint(float(w)*(x[i]-xmin)/(xmax-xmin)), cint(float(h)*(y[i]-ymin)/(ymax-ymin)))
    result.add(p)

proc main() =
  var
    surf = sdl2.createRGBSurface(w, h, 32)
    rend = sdl2.createSoftwareRenderer(surf)
    black = (0'u8, 0'u8, 0'u8, 255'u8)
    white = (255'u8, 255'u8, 255'u8, 255'u8)
    red = (255'u8, 0'u8, 0'u8, 255'u8)
    green = (0'u8, 255'u8, 0'u8, 255'u8)
    blue = (0'u8, 0'u8, 255'u8, 255'u8)
    z = toSeq(0..99)
    x = map(z, proc(x: int): float = float(x))
    y = toSeq(rnds(100))
    p = genPoints(x, y)

  echo x
  echo y
  echo p

  rend.setDrawColor(white)
  rend.clear()

  rend.setDrawColor(blue)
  discard rend.drawLines(p[0].addr(), 100)

  #rend.drawLine(0,0,w,h)
  surf.saveBMP("test.bmp")
  sdl2.destroy(rend)
  sdl2.destroy(surf)
  sdl2.quit()

when isMainModule:
  main()
