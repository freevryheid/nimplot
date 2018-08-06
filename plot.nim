import
  colors
  , random
  , cairo

type
  CColor = tuple
    r,g,b: cdouble

proc ccolor(c: Color): CColor =
  var x = c.extractRGB()
  result.r = cdouble(x.r/255)
  result.g = cdouble(x.g/255)
  result.b = cdouble(x.b/255)

type
  ColorTable = array[6,CColor]
  Size = tuple
    w, h: cint
  Font = object
    name: string
    slant: font_slant_t    # TODO: change this
    weight: font_weight_t  # TODO: change this
    size: float
    fg: CColor
    #bg: #TODO
  Loc = enum  # legend location - TODO allow x,y point
    NORTH, SOUTH, EAST, WEST
  Legend = object
  #  text: string
  #  font: Font
  #  show: bool
  #  loc: Loc
  LineType* = enum
    NONE, SOLID #,Gradient
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
    font: Font
    text: string
    loc: Loc  # location
  Chart = object of RootObj
    ctype: ChartType
    size: Size  # chart size
    nsets: int  # number of datasets
    series*: DataSets
    colorTable: ColorTable
    gap: int  # between stuff
    frame: Line  # chart frame
    title: Title
  Scatter* = object of Chart

const
  BLACK = ccolor(colBlack)
  CHART_WIDTH = 600
  CHART_HEIGHT = 400
  CHART_GAP = 10  # Applied through between blocks
  TITLE_FONT_NAME = "serif"
  TITLE_FONT_SLANT = FONT_SLANT_NORMAL
  TITLE_FONT_WEIGHT = FONT_WEIGHT_BOLD
  TITLE_FONT_SIZE = 12
  TITLE_FONT_FG = BLACK  # foreground color
  TITLE_LOC = NORTH
  TITLE_TEXT = ""
  FRAME_LTYPE = SOLID
  FRAME_THICK = 5
  FRAME_COLOR = BLACK
  LINE_LTYPE = SOLID
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
  var size: Size
  var titleFont: Font
  size.w = CHART_WIDTH
  size.h = CHART_HEIGHT
  result.size = size
  result.gap = CHART_GAP
  result.series = @[]
  result.colorTable = COLORTABLE01
  # chart frame
  result.frame.ltype = FRAME_LTYPE
  result.frame.thick = FRAME_THICK
  result.frame.color = FRAME_COLOR
  # chart title
  titleFont.fg = TITLE_FONT_FG
  titleFont.name = TITLE_FONT_NAME
  titleFont.size = TITLE_FONT_SIZE
  titleFont.slant = TITLE_FONT_SLANT
  titleFont.weight = TITLE_FONT_WEIGHT
  result.title.font = titleFont
  result.title.loc = TITLE_LOC
  result.title.text = TITLE_TEXT


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
  var te: ptr text_extents_t
  var xcoord, ycoord: int
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
  if len(chart.title.text) > 0:
    result.set_source_rgb(chart.title.font.fg.r, chart.title.font.fg.g, chart.title.font.fg.b)
    result.select_font_face(chart.title.font.name, chart.title.font.slant, chart.title.font.weight)
    result.set_font_size(chart.title.font.size)
    result.text_extents(chart.title.text.cstring, te)
    xcoord = 0
    case chart.title.loc:
      of "north":
        ycoord = chart.frame.thick + chart.gap + chart.title.font.size
      of "south":
        ycoord = chart.size.h - chart.frame.thick - chart.gap
      else: discard
    result.move_to(xcoord, ycoord)
    result.show_text(chart.title.text.cstring)
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
