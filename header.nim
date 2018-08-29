import colors

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

  Size = object
    w, h: float

  Font = object
    name: string
    slant: font_slant_t
    weight: font_weight_t
    size: float
    color: CColor

  LineType* = enum
    NOLINE, SOLID, DASH, DOTDASH

  MarkerType* = enum
    NOMARKER, CIRCLE, SQUARE, DIAMOND

  Line* = object
    ltype*: LineType
    color*: CColor
    thick*: float

  Marker* = object
    mtype*: MarkerType
    color*: CColor
    size*: float
    fill*: bool

  Style* = object
    line*: Line
    marker*: Marker
    name*: string

  Styles = seq[Style]

  DataSet* = object
    chart: Chart
    x*: seq[float]  # primary axis
    y*: seq[float]  # primary axis
    xmin, xmax, ymin, ymax: float  # extrema
    style*: Style

  DataSets = seq[DataSet]

  ChartType = enum
    SCATTER, LINECHART, BARCHART, PIECHART

  Title* = object
    font*: Font
    text*: string
    size: Size
    frame*: Line
    gap*: float

  Grid* = object
    hor*: Line
    vert*: Line

  Area*   = object
    frame*: Line
    grid*: Grid

  Legend* = object
    show*: bool
    frame*: Line

  Chart = object of RootObj
    ctype: ChartType
    size: Size  # chart size
    nsets: int  # number of datasets
    series: DataSets
    colorTable: ColorTable
    gap: float  # between stuff
    frame: Line  # chart frame
    title: Title
    area: Area
    legend: Legend

  ScatterChart* = object of Chart

const
  # colors
  BLACK = ccolor(colBlack)
  RED = ccolor(colRed)
  GREEN = ccolor(colGreen)
  BLUE = ccolor(colBlue)
  YELLOW = ccolor(colYellow)
  CYAN = ccolor(colCyan)
  MAGENTA = ccolor(colMagenta)

  COLTBL = [RED
    , GREEN
    , BLUE
    , YELLOW
    , CYAN
    , MAGENTA]

  # chart
  CHART_WIDTH = 600.0
  CHART_HEIGHT = 400.0
  CHART_GAP = 10.0

  # chart title
  CHART_TITLE_FONT_NAME = "sans"
  CHART_TITLE_FONT_SLANT = FONT_SLANT_NORMAL
  CHART_TITLE_FONT_WEIGHT = FONT_WEIGHT_BOLD
  CHART_TITLE_FONT_SIZE = 30.0
  CHART_TITLE_FONT_COLOR = BLACK
  CHART_TITLE_TEXT = ""
  CHART_TITLE_GAP = 5.0

  # chart frame
  CHART_FRAME_LTYPE = NOLINE
  CHART_FRAME_THICK = 5.0
  CHART_FRAME_COLOR = BLACK

  # chart title frame
  CHART_TITLE_FRAME_LTYPE = NOLINE
  CHART_TITLE_FRAME_THICK = 1.0
  CHART_TITLE_FRAME_COLOR = BLACK

  # chart area
  CHART_AREA_FRAME_LTYPE = SOLID
  CHART_AREA_FRAME_THICK = 1.0
  CHART_AREA_FRAME_COLOR = BLACK

  # chart legend
  CHART_LEGEND_FRAME_COLOR = BLACK
  CHART_LEGEND_FRAME_LTYPE = SOLID
  CHART_LEGEND_FRAME_THICK = 1
  CHART_LEGEND_SHOW = true

# data styles
var
  STYTBL: Styles
for i, c in COLTBL:
  var
    line: Line
    mark: Marker
    sty: Style
  line.color = c
  line.ltype = SOLID
  line.thick = 1
  mark.color = c
  mark.mtype = NOMARKER
  mark.fill = false
  mark.size = 5
  sty.line = line
  sty.marker = mark
  sty.name = "Series" & $(i+1)
  STYTBL.add(sty)
