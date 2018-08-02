import
  colors
  , cairo


1. Warm Flame

#ff9a9e → #fad0c4

2. Juicy Peach


#ffecd2 → #fcb69f

3. Lady Lips


#ff9a9e → #fecfef

4. Winter Neva


#a1c4fd → #c2e9fb

5. Heavy Rain


#cfd9df → #e2ebf0

6. Cloudy Knoxville


#fdfbfb → #ebedee

7. Saint Petersberg


#f5f7fa → #c3cfe2

8. Plum Plate


#667eea → #764ba2

9. Everlasting Sky


#fdfcfb → #e2d1c3

10. Happy Fisher


#89f7fe → #66a6ff

11. Fly High


#48c6ef → #6f86d6

12. Strong Bliss


Multiple colors

13. Fresh Milk


#feada6 → #f5efef

14. Great Whale


#a3bded → #6991c7

15. Aqua Splash


#13547a → #80d0c7

16. Clean Mirror


#93a5cf → #e4efe9

17. Premium Dark


#434343 → #000000

18. Cochiti Lake


#93a5cf → #e4efe9

19. Passionate Bed


#ff758c → #ff7eb3

20. Mountain Rock


#868f96 → #596164

21. Desert Hump


#c79081 → #dfa579

22. Eternal Constance


#09203f → #537895

23. Healthy Water


#96deda → #50c9c3

24. Vicious Stance


#29323c → #485563

25. Nega


#ee9ca7 → #ffdde1

26. Night Sky


#1e3c72 → #2a5298

27. Gentle Care


#ffc3a0 → #ffafbd

28. Angel Care


Multiple colors

29. Morning Salad


#B7F8DB → #50A7C2

30. Deep Relief

1. Roseanna


#ffafbd → #ffc3a0



2. Sexy Blue


#2193b0 → #6dd5ed



3. Purple Love


#cc2b5e → #753a88



4. Piglet


#ee9ca7 → #ffdde1



5. Mauve


#42275a → #734b6d



6. 50 Shades of Grey


#bdc3c7 → #2c3e50



7. A Lost Memory


#de6262 → #ffb88c



8. Socialive


#06beb6 → #48b1bf



9. Cherry


#eb3349 → #f45c43



10. Pinky


#dd5e89 → #f7bb97



11. Lush


#56ab2f → #a8e063



12. Kashmir


#614385 → #516395



13. Tranquil


#eecda3 → #ef629f



14. Pale Wood


#eacda3 → #d6ae7b



15. Green Beach


#02aab0 → #00cdac



16. Sha La La


#d66d75 → #e29587



17. Frost


#000428 → #004e92



18. Almost


#ddd6f3 → #faaca8



19. Virgin America


#7b4397 → #dc2430



20. Endless River


#43cea2 → #185a9d



21. Purple White


#ba5370 → #f4e2d8



22. Bloody Mary


#ff512f → #dd2476



23. Can you feel the love tonight


#4568dc → #b06ab3



24. Bourbon


#ec6f66 → #f3a183



25. Dusk


#ffd89b → #19547b



26. Relay


#3a1c71 → #d76d77 → #ffaf7b



27. Decent


#4ca1af → #c4e0e5



28. Sweet Morning


#ff5f6d → #ffc371



29. Scooter


#36d1dc → #5b86e5



30. Celestial


#c33764 → #1d2671



31. Royal


#141e30 → #243b55



32. Ed’s Sunset Gradient


#ff7e5f → #feb47b



33. Peach


#ed4264 → #ffedbc



34. Sea Blue


#2b5876 → #4e4376



35. Orange Coral


#ff9966 → #ff5e62



36. Aubergine


#aa076b → #61045f


#FFE985 → #FA742B

22.


#FFA6B7 → #1E2AD2

23.


#FFAA85 → #B3315F

24.


#72EDF2 → #5151E5

25.


#FF9D6C → #BB4E75

26.


#3B2667 → #BC78EC

27.


#FAB2FF → #1904E5


const
  CHART_WIDTH = 600
  CHART_HEIGHT = 400

type
  CColor = tuple
    r,g,b: cdouble
  Point* = tuple
    x, y : float
  Points* = seq[Point]
  Size* = tuple
    w, h: cint
  Serie* = object
    legend*: string
    data*: Points
  Series* = seq[Serie]
  Chart* = object of RootObj
    size*: Size
  Scatter* = object of Chart
    series*: Series

proc ccolor(c: Color): CColor =
  var x = c.extractRGB()
  result.r = cdouble(x.r/255)
  result.g = cdouble(x.g/255)
  result.b = cdouble(x.b/255)

proc newScatter*(): Scatter =
  var size:Size
  size.w = CHART_WIDTH
  size.h = CHART_HEIGHT
  result.size = size

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

proc plot*(chart: Scatter): ptr cairo_t =
  let sf = image_surface_create(FORMAT_ARGB32, chart.size.w, chart.size.h)
  defer: surface_destroy(sf)
  result = create(sf)
  result.set_source_rgb(0, 0, 0)

proc writePNG*(cr: ptr cairo_t; png:string) =
  discard surface_write_to_png(get_target(cr), png)
