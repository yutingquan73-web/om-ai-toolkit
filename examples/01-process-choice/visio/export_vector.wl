(* Render the model-derived polygons without RegionPlot's sampling mesh. *)
pcVectorDir = DirectoryName[$InputFileName];
If[! ValueQ[pcVectorInput], pcVectorInput = FileNameJoin[{pcVectorDir, "geometry.json"}]];
If[! ValueQ[pcVectorOutput], pcVectorOutput = FileNameJoin[{pcVectorDir, "process_choice.svg"}]];
If[FileExistsQ[pcVectorOutput], Print["SVG output already exists"]; Exit[1]];
pcVectorData = Import[pcVectorInput, "RawJSON"];
pcVectorRegions = pcVectorData["regions"];
pcVectorBoundaries = pcVectorData["boundaries"];
pcVectorFigure = Graphics[{
   {RGBColor[0.72, 0.84, 0.96], EdgeForm[None], Polygon[pcVectorRegions["A"]]},
   {RGBColor[0.98, 0.81, 0.57], EdgeForm[None], Polygon[pcVectorRegions["B"]]},
   {RGBColor[0.71, 0.88, 0.76], EdgeForm[None], Polygon[pcVectorRegions["C"]]},
   {Black, AbsoluteThickness[1.5], Line /@ Values[pcVectorBoundaries]},
   {Black, PointSize[0.013], Point[pcVectorData["triplePoint"]]},
   {Black, Table[Text[Style[name, 18, Bold], Mean[pcVectorRegions[name]]], {name, {"A", "B", "C"}}]}
  }, Frame -> False, Axes -> False, ImagePadding -> 0,
  PlotRange -> {{0, pcVectorData["qMax"]}, {0, pcVectorData["fMax"]}},
  PlotRangePadding -> None, ImageSize -> 620, AspectRatio -> 2/3];
If[Export[pcVectorOutput, pcVectorFigure, "SVG"] === $Failed, Exit[1]];
Print["Exported polygon vector figure"];
