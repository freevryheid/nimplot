import cairo

include "header.nim"  # defaults

proc defaults(chart: var Chart) =
  # assign defaults as defined in header.nim
  var
    size: Size
    titleFont: Font

  # chart
  size.w = CHART_WIDTH
  size.h = CHART_HEIGHT
  chart.size = size
  chart.gap = CHART_GAP
  chart.series = @[]
  chart.colorTable = COLTBL

  # chart frame
  chart.frame.ltype = CHART_FRAME_LTYPE
  chart.frame.thick = CHART_FRAME_THICK
  chart.frame.color = CHART_FRAME_COLOR

  # chart title
  titleFont.color = CHART_TITLE_FONT_COLOR
  titleFont.name = CHART_TITLE_FONT_NAME
  titleFont.size = CHART_TITLE_FONT_SIZE
  titleFont.slant = CHART_TITLE_FONT_SLANT
  titleFont.weight = CHART_TITLE_FONT_WEIGHT

  chart.title.font = titleFont
  chart.title.text = CHART_TITLE_TEXT
  chart.title.frame.ltype = CHART_TITLE_FRAME_LTYPE
  chart.title.frame.thick = CHART_TITLE_FRAME_THICK
  chart.title.frame.color = CHART_TITLE_FRAME_COLOR
  chart.title.gap = CHART_TITLE_GAP

  # chart area
  chart.area.frame.ltype = CHART_AREA_FRAME_LTYPE
  chart.area.frame.thick = CHART_TITLE_FRAME_THICK
  chart.area.frame.color = CHART_TITLE_FRAME_COLOR

  # chart legend
  chart.legend.frame.color = CHART_LEGEND_FRAME_COLOR
  chart.legend.frame.ltype = CHART_LEGEND_FRAME_LTYPE
  chart.legend.frame.thick = CHART_LEGEND_FRAME_THICK
  chart.legend.show = CHART_LEGEND_SHOW

proc newScatter*(): ScatterChart =
  result.ctype = SCATTER
  result.defaults()

proc newDataSet*(chart: var Chart): DataSet =
  result.chart = chart
  result.style = STYTBL[chart.nsets]
  inc chart.nsets

# proc extrema(series: var DataSets) =
#   var smin, smax, tmin, tmax: float
#   for i, s in series.mpairs:
#     smin = min(s.x)
#     smax = max(s.x)
#     tmin = min(s.y)
#     tmax = max(s.y)
#     if i == 0:
#       s.xmin = smin
#       s.xmax = smax
#       s.ymin = tmin
#       s.ymax = tmax
#     else:
#       if smin < s.xmin:
#         s.xmin = smin
#       if smax > s.xmax:
#         s.xmax = smax
#       if tmin < s.ymin:
#         s.ymin = tmin
#       if tmax > s.ymax:
#         s.ymax = tmax

proc drawFrame(c: ptr cairo_t; chart: Chart) =
  if chart.frame.ltype != NOLINE:
    c.set_source_rgb(chart.frame.color.r, chart.frame.color.g, chart.frame.color.b)
    c.set_line_width(chart.frame.thick)
    c.rectangle(0, 0, chart.size.w.float, chart.size.h.float)
    c.stroke()

proc drawTitle(c: ptr cairo_t; chart: var Chart) =
  if len(chart.title.text) > 0:
    var te: text_extents_t
    var ttx, tty: float # for title text coords
    var tfx0, tfx1, tfy0, tfy1: float  # title frame coords
    c.set_source_rgb(chart.title.font.color.r, chart.title.font.color.g, chart.title.font.color.b)
    c.select_font_face(chart.title.font.name, chart.title.font.slant, chart.title.font.weight)
    c.set_font_size(chart.title.font.size)
    c.text_extents(chart.title.text.cstring, te.addr)
    chart.title.size.h = te.height
    chart.title.size.w = te.width
    if chart.title.frame.ltype == NOLINE:
      ttx = (chart.size.w - chart.title.size.w) / 2.0
      tty = chart.frame.thick + chart.gap + chart.title.size.h
      tfx0 = chart.gap
      tfx1 = chart.size.w - 2.0*chart.gap
    else:
      ttx = (chart.size.w - chart.title.size.w - 2.0*chart.title.frame.thick - 2.0*chart.title.gap) / 2.0
      tfx0 = chart.frame.thick + chart.gap
      tfx1 = chart.size.w - 2.0*chart.frame.thick - 2.0*chart.gap
      tty = chart.frame.thick + chart.gap + chart.title.size.h + chart.title.gap + chart.title.frame.thick
      tfy0 = chart.frame.thick + chart.gap
      tfy1 = 2.0*chart.title.frame.thick + 2.0*chart.title.gap + chart.title.size.h
      # draw frame
      c.set_source_rgb(chart.title.frame.color.r, chart.title.frame.color.g, chart.title.frame.color.b)
      c.set_line_width(chart.title.frame.thick)
      c.rectangle(tfx0, tfy0, tfx1, tfy1)
      c.stroke()
    c.move_to(ttx, tty)
    c.show_text(chart.title.text.cstring)

proc drawArea(c: ptr cairo_t; chart: Chart) =
  if chart.area.frame.ltype != NOLINE:
    if len(chart.title.text) > 0:
      # we have a title
      if chart.legend.show:
        # we have a legend
        echo "area beneath title and above legend"
      else:
        echo "area beneath title"
    else:
      if chart.legend.show:
        echo "area above legend"
      else:
        echo "full"

    c.set_source_rgb(chart.area.frame.color.r, chart.area.frame.color.g, chart.area.frame.color.b)
    c.set_line_width(chart.area.frame.thick)
    c.rectangle(0, 0, chart.size.w.float, chart.size.h.float)
    c.stroke()

# proc drawData(c: ptr cairo_t; chart: var Chart) =
#   extrema(chart.series)
#   for s in chart.series:
#     if s.line.ltype == NONE:
#       continue
#     c.set_source_rgb(s.line.color.r, s.line.color.g, s.line.color.b)
#     c.set_line_width(s.line.thick)
#     # TODO assert len(x) == len(y)
#     for i in 0..len(s.x)-2:
#       c.move_to(chart.size.w*(s.x[i]-s.xmin)/(s.xmax-s.xmin), chart.size.h - chart.title.h - chart.size.h*(s.y[i]-s.ymin)/(s.ymax-s.ymin))
#       c.line_to(chart.size.w*(s.x[i+1]-s.xmin)/(s.xmax-s.xmin), chart.size.h - chart.title.h - chart.size.h*(s.y[i+1]-s.ymin)/(s.ymax-s.ymin))
#       c.stroke()

proc drawLegend(c: ptr cairo_t; chart: Chart) =
  if chart.legend.show:
    for s in chart.series:
      echo s

proc plot*(chart: var Chart): ptr cairo_t =
  let sf = image_surface_create(FORMAT_ARGB32, chart.size.w.cint, chart.size.h.cint)
  defer: surface_destroy(sf)
  result = create(sf)
  # chart frame
  result.drawFrame(chart)
  # chart title
  result.drawTitle(chart)
  # chart legend
  result.drawLegend(chart)
  # chart area
  result.drawArea(chart)
  # chart data
  #result.drawData(chart)

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
  scatter.frame.ltype = SOLID
  scatter.plot().writePNG("test.png")

when isMainModule:
  main()
