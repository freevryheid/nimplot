import
  colors
  , random
  , cairo

const
  CHART_WIDTH = 600
  CHART_HEIGHT = 400
  DRAW_AREA = 0.8

type
  CColor = tuple
    r,g,b: cdouble
  ColSeq = seq[CColor]
  Size = tuple
    w, h: cint
  #Legend = object
  #  text: Font
  LineType = enum
    None, Solid #,Gradient
  Line = object
    ltype: LineType
    color: CColor
    thick: float
  Marker = object
  DataSet* = object
    #legend*: Legend
    x*: seq[float]
    y*: seq[float]
    #x1*: seq[float]
    #y1*: seq[float]
    xmin, xmax, ymin, ymax: float
    #xAxis: Axis
    #yAxis: Axis
    #y0Axis: Axis
    #y1Axis: Axis
    line: Line
    #marker: Marker
    #markerType: MarkerType
    #markerColor*: CColor
    #markerSize*: float
  DataSets* = seq[DataSet]
  ChartType = enum
    scatter
  Chart* = object of RootObj
    ctype: ChartType
    size*: Size  # chart size
    series*: DataSets
    colSeq: ColSeq
    drawArea*: float # as fraction of size
  Scatter* = object of Chart
  Extremes = object
    xmin, xmax, ymin, ymax: cdouble

proc ccolor(c: Color): CColor =
  var x = c.extractRGB()
  result.r = cdouble(x.r/255)
  result.g = cdouble(x.g/255)
  result.b = cdouble(x.b/255)

const colortable = [
  ccolor(colRed),
  ccolor(colGreen),
  ccolor(colBlue)]

proc newScatter*(): Scatter =
  result.ctype = scatter
  var size:Size
  size.w = CHART_WIDTH
  size.h = CHART_HEIGHT
  result.size = size
  result.drawArea = DRAW_AREA
  result.series = @[]

proc setWidth*(chart: var Chart; w: cint) =
  chart.size.w = w

proc getWidth*(chart: Chart): cint =
  result = chart.size.w

proc setHeight*(chart: var Chart; h: cint) =
  chart.size.h = h

proc getHeight*(chart: Chart): cint =
  result = chart.size.h

proc setSize*(chart: var Chart; size: Size) =
  chart.size = size

proc getSize*(chart: Chart): Size =
  result = chart.size

proc extrema(series: var DataSets) =
  var smin,smax,tmin,tmax: float
  for i, s in series.mpairs:
    smin = min(s.x)
    smax = max(s.x)
    tmin = min(s.y)
    tmax = max(s.y)
    if i == 0:
      s.xmin = smin
      s.xmax = smax
      s.ymin = tmin
      s.ymax = tmax
    else:
      if smin < s.xmin:
        s.xmin = smin
      if smax > s.xmax:
        s.xmax = smax
      if tmin < s.ymin:
        s.ymin = tmin
      if tmax > s.ymax:
        s.ymax = tmax

proc addlines(series: var DataSets) =
  for s in series:
    if s.line == nil:
      s.line.thick = 0.5
      s.line.color = ccolor(colBlack)
      s.line.ltype = Solid

proc examine(chart: Chart) =
  if len(chart.series) > 0:
    chart.series.extrema()
    chart.series.addlines()

proc plot*(chart: Chart): ptr cairo_t =
  chart.examine()
  let sf = image_surface_create(FORMAT_ARGB32, chart.size.w, chart.size.h)
  defer: surface_destroy(sf)
  result = create(sf)
  # lines
  for s in chart.series:
    result.set_source_rgb(rand(1.0), rand(1.0), rand(1.0))
    result.set_line_width(0.5)

    for i in 0..len(s.x)-2:
      result.move_to(chart.size.w.float*(s.x[i]-ex.xmin)/(ex.xmax-ex.xmin),chart.size.h.float*(s.y[i]-ex.ymin)/(ex.ymax-ex.ymin))
      result.line_to(chart.size.w.float*(s.x[i+1]-ex.xmin)/(ex.xmax-ex.xmin),chart.size.h.float*(s.y[i+1]-ex.ymin)/(ex.ymax-ex.ymin))
      result.stroke()
  # chart frame
  result.set_source_rgb(0, 0, 0)
  result.rectangle(0, 0, chart.size.w.float, chart.size.h.float)
  result.stroke()

proc writePNG*(cr: ptr cairo_t; png:string) =
  discard surface_write_to_png(get_target(cr), png)
