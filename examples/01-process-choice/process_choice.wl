(* Original teaching example: minimum-cost production process choice.
   No external data or packages. Exact arithmetic preserves tie rules.
   Evaluate this file, then inspect pcValidation and pcFigure.
   This file does not export or overwrite any files. *)

ClearAll[pcQ, pcF, pcFixedB, pcQMax, pcFMax, pcQSwitch, pcFTriple,
  pcCostA, pcCostB, pcCostC, pcRegionA, pcRegionB, pcRegionC,
  pcClassify, pcDirectChoice, pcGrid, pcGridMismatches, pcSamples,
  pcSampleResults, pcSymbolicChecks, pcValidation, pcPlotA, pcPlotB,
  pcPlotC, pcBoundaries, pcFigure];

(* 1. Parameters. Try pcFixedB = 16 after reproducing the baseline. *)
pcFixedB = 12;
pcQMax = 12;
pcFMax = 24;
(* This bound keeps all three boundary segments visible in this lesson. *)
If[! TrueQ[0 < pcFixedB < Min[2 pcQMax, 4 pcFMax/5, pcFMax - pcQMax/2]],
  Print["Parameter outside this lesson's plotting range."]; Abort[]];
pcQSwitch = pcFixedB/2;
pcFTriple = 5 pcFixedB/4;

(* 2. Costs: all three processes are feasible on the plotted rectangle. *)
pcCostA[q_] := 3 q;
pcCostB[q_] := pcFixedB + q;
pcCostC[q_, f_] := f + q/2;

(* 3. Simplified regions. Ties are assigned in the order A, B, C. *)
pcRegionA = pcQ <= pcQSwitch && pcF >= 5 pcQ/2;
pcRegionB = pcQ > pcQSwitch && pcF >= pcFixedB + pcQ/2;
pcRegionC = pcF < Min[5 pcQ/2, pcFixedB + pcQ/2];
pcClassify[q_, f_] := Which[
  q <= pcQSwitch && f >= 5 q/2, "A",
  q > pcQSwitch && f >= pcFixedB + q/2, "B",
  f < Min[5 q/2, pcFixedB + q/2], "C",
  True, "Unclassified"];

(* 4. Independent comparator uses raw costs, not simplified regions. *)
pcDirectChoice[q_, f_] := Module[{values},
  values = {pcCostA[q], pcCostB[q], pcCostC[q, f]};
  {"A", "B", "C"}[[First[FirstPosition[values, Min[values]]]]]
];
pcGrid = Tuples[{Range[0, pcQMax, 1/4], Range[0, pcFMax, 1/2]}];
pcGridMismatches = Select[pcGrid,
  pcClassify @@ # =!= pcDirectChoice @@ # &];
pcSamples = {{0, 0}, {0, 24}, {2, 10}, {2, 1}, {10, 24},
  {4, 10}, {6, 10}, {6, 15}, {6, 20}, {12, 0}, {12, 18},
  {pcQSwitch, pcFTriple}, {pcQSwitch, pcFTriple - 1/100},
  {pcQSwitch - 1/100, pcFTriple},
  {pcQSwitch + 1/100, pcFTriple}};
pcSampleResults = ({#, pcClassify @@ #, pcDirectChoice @@ #} &) /@ pcSamples;
pcSymbolicChecks = {
  Reduce[0 <= pcQ <= pcQMax && 0 <= pcF <= pcFMax &&
    Xor[pcRegionA, pcCostA[pcQ] <= pcCostB[pcQ] &&
      pcCostA[pcQ] <= pcCostC[pcQ, pcF]], {pcQ, pcF}, Reals] === False,
  Reduce[0 <= pcQ <= pcQMax && 0 <= pcF <= pcFMax &&
    Xor[pcRegionB, pcCostB[pcQ] < pcCostA[pcQ] &&
      pcCostB[pcQ] <= pcCostC[pcQ, pcF]], {pcQ, pcF}, Reals] === False,
  Reduce[0 <= pcQ <= pcQMax && 0 <= pcF <= pcFMax &&
    Xor[pcRegionC, pcCostC[pcQ, pcF] < pcCostA[pcQ] &&
      pcCostC[pcQ, pcF] < pcCostB[pcQ]], {pcQ, pcF}, Reals] === False
};
pcValidation = <|
  "FixedCostB" -> pcFixedB,
  "TriplePoint" -> {pcQSwitch, pcFTriple},
  "GridPoints" -> Length[pcGrid],
  "GridMismatches" -> Length[pcGridMismatches],
  "SymbolicRegionChecks" -> pcSymbolicChecks,
  "SampleChecksPassed" -> And @@ (#[[2]] === #[[3]] & /@ pcSampleResults),
  "TriplePointChoice" -> pcClassify[pcQSwitch, pcFTriple]
|>;
If[Length[pcGridMismatches] != 0 || ! TrueQ[And @@ pcSymbolicChecks] ||
    ! TrueQ[pcValidation["SampleChecksPassed"]],
  Print["Validation failed. Inspect pcValidation and pcSampleResults."]; Abort[]];

(* 5. Draw each region separately; colors are editable example choices. *)
pcPlotA = RegionPlot[Evaluate[pcRegionA], {pcQ, 0, pcQMax},
  {pcF, 0, pcFMax}, PlotStyle -> RGBColor[0.72, 0.84, 0.96],
  BoundaryStyle -> None, PlotPoints -> 40, MaxRecursion -> 1];
pcPlotB = RegionPlot[Evaluate[pcRegionB], {pcQ, 0, pcQMax},
  {pcF, 0, pcFMax}, PlotStyle -> RGBColor[0.98, 0.81, 0.57],
  BoundaryStyle -> None, PlotPoints -> 40, MaxRecursion -> 1];
pcPlotC = RegionPlot[Evaluate[pcRegionC], {pcQ, 0, pcQMax},
  {pcF, 0, pcFMax}, PlotStyle -> RGBColor[0.71, 0.88, 0.76],
  BoundaryStyle -> None, PlotPoints -> 40, MaxRecursion -> 1];

(* Only optimal switching segments are shown, not full pairwise equalities. *)
pcBoundaries = Graphics[{Black, AbsoluteThickness[1.5],
  Line[{{0, 0}, {pcQSwitch, pcFTriple}}],
  Line[{{pcQSwitch, pcFTriple}, {pcQMax, pcFixedB + pcQMax/2}}],
  Line[{{pcQSwitch, pcFTriple}, {pcQSwitch, pcFMax}}],
  PointSize[0.013], Point[{pcQSwitch, pcFTriple}]}];
pcFigure = Show[pcPlotA, pcPlotB, pcPlotC, pcBoundaries,
  Frame -> True, Axes -> False, PlotRange -> {{0, pcQMax}, {0, pcFMax}},
  PlotRangePadding -> None, FrameLabel -> {"Quantity q", "Fixed cost f"},
  PlotLabel -> "Minimum-cost process (ties: A, then B, then C)",
  ImageSize -> 620, AspectRatio -> 2/3,
  Epilog -> {Black,
    Text[Style["A", 18, Bold], {pcQSwitch/2, (5 pcQSwitch/4 + pcFMax)/2}],
    Text[Style["B", 18, Bold], {(pcQSwitch + pcQMax)/2,
      (pcFixedB + (pcQSwitch + pcQMax)/4 + pcFMax)/2}],
    Text[Style["C", 18, Bold], {pcQMax/2,
      Min[5 pcQMax/4, pcFixedB + pcQMax/4]/2}]}];

pcValidation = Join[pcValidation, <|"GraphicsConstructed" ->
  And @@ (Head[#] === Graphics & /@ {pcPlotA, pcPlotB, pcPlotC, pcFigure})|>];
pcFigure
