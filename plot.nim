import
  colors
  , random
  , cairo

type
  CColor = tuple
    r,g,b: cdouble
  ColorTable = array[6,CColor]
  Size = tuple
    w, h: cint
  Font = object
  Loc = enum  # legend location - TODO allow x,y point
    north, south, east, west
  Legend = object
  #  text: string
  #  font: Font
  #  show: bool
  #  loc: Loc
  LineType* = enum
    None, Solid #,Gradient
  Line* = object
    ltype*: LineType
    color*: CColor
    thick*: float
    show*: bool
  Marker* = object
#    mtype*: MarkerType
#    color*: CColor
#    size*: float
  DataSet* = object
    chart: Chart
    legend*: Legend
    x*: seq[float]  # primary axis
    y*: seq[float]
    u*: seq[float]  # secondary axis
    v*: seq[float]
    xmin, xmax, ymin, ymax: float  # extrema 1
    umin, umax, vmin, vmax: float  # extrema 2
#    xAxis*: Axis
#    yAxis*: Axis
#    uAxis*: Axis
#    vAxis*: Axis
    line*: Line
#    marker*: Marker
  DataSets = seq[DataSet]
  ChartType = enum
    scatter
  Title = object
    text: string
    color: CColor
    h: float  # height
  Chart = object of RootObj
    ctype: ChartType
    size: Size  # chart size
    nsets: int  # number of datasets
    series*: DataSets
    colorTable: ColorTable
    frame: Line  # chart frame
    title: Title
  Scatter* = object of Chart

proc ccolor(c: Color): CColor =
  var x = c.extractRGB()
  result.r = cdouble(x.r/255)
  result.g = cdouble(x.g/255)
  result.b = cdouble(x.b/255)

const
  BLACK = ccolor(colBlack)
  CHART_WIDTH = 600
  CHART_HEIGHT = 400
  CHART_GAP = 10
  TITLE_HEIGHT = 100
  TITLE_COLOR = BLACK
  TITLE_LOC = north
  FRAME_LTYPE = Solid
  FRAME_THICK = 5
  FRAME_COLOR = BLACK
  LINE_LTYPE = Solid
  LINE_THICK = 1
  COLORTABLE01 = [
    ccolor(colRed),
    ccolor(colGreen),
    ccolor(colBlue),
    ccolor(colYellow),
    ccolor(colCyan),
    ccolor(colMagenta)]

proc newDataSet*(chart: var Chart): DataSet =
  result.chart = chart
  # lines
  result.line.ltype = LINE_LTYPE
  result.line.thick = LINE_THICK
  result.line.color = chart.colorTable[chart.nsets]
  # markers
  # axis
  # legend
  inc chart.nsets

proc newScatter*(): Scatter =
  # chart options
  result.ctype = scatter
  var size:Size
  size.w = CHART_WIDTH
  size.h = CHART_HEIGHT
  result.size = size
  result.series = @[]
  result.colorTable = COLORTABLE01
  # chart frame
  result.frame.ltype = FRAME_LTYPE
  result.frame.thick = FRAME_THICK
  result.frame.color = FRAME_COLOR
  # chart title
  result.title.h = TITLE_HEIGHT
  result.title.color = TITLE_COLOR
  # chart

# TODO: Update to check secondary axis as well
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

proc plot*(chart: var Chart): ptr cairo_t =
  let sf = image_surface_create(FORMAT_ARGB32, chart.size.w, chart.size.h)
  defer: surface_destroy(sf)
  result = create(sf)
  # chart frame
  if chart.frame.ltype != None:
    result.set_source_rgb(chart.frame.color.r, chart.frame.color.g, chart.frame.color.b)
    result.set_line_width(chart.frame.thick)
    result.rectangle(0, 0, chart.size.w.float, chart.size.h.float)
    result.stroke()
  # chart title



  # lines
  extrema(chart.series)
  for s in chart.series:
    if s.line.ltype == None:
      continue
    result.set_source_rgb(s.line.color.r, s.line.color.g, s.line.color.b)
    result.set_line_width(s.line.thick)
    # TODO assert len(x) == len(y)
    for i in 0..len(s.x)-2:
      result.move_to(chart.size.w.float*(s.x[i]-s.xmin)/(s.xmax-s.xmin), chart.size.h.float - chart.title.h - chart.size.h.float*(s.y[i]-s.ymin)/(s.ymax-s.ymin))
      result.line_to(chart.size.w.float*(s.x[i+1]-s.xmin)/(s.xmax-s.xmin), chart.size.h.float - chart.title.h - chart.size.h.float*(s.y[i+1]-s.ymin)/(s.ymax-s.ymin))
      result.stroke()

proc writePNG*(cr: ptr cairo_t; png:string) =
  discard surface_write_to_png(get_target(cr), png)


proc main() =
  var
    scatter = newScatter()
    ds = scatter.newDataSet()
    x = @[0.0, 0.1, 0.2, 0.3, 0.4, 0.5]
    y = @[1.0, 2.1, 3.2, 4.3, 5.4, 6.5]

  ds.x = x
  ds.y = y
  scatter.series.add(ds)
  scatter.plot().writePNG("test1.png")

when isMainModule:
  main()
