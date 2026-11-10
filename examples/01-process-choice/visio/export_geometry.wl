(* Run in a fresh kernel. Only the output path below is written. *)
pcVisioDir = DirectoryName[$InputFileName];
If[! ValueQ[pcVisioOutput], pcVisioOutput = FileNameJoin[{pcVisioDir, "geometry.json"}]];
If[FileExistsQ[pcVisioOutput], Print["Output already exists: geometry.json"]; Exit[1]];
If[! ValueQ[pcVisioSource], pcVisioSource = FileNameJoin[{pcVisioDir, "..", "process_choice.wl"}]];
If[! FileExistsQ[pcVisioSource], Print["Model source does not exist"]; Exit[1]];
Clear[pcValidation];
If[CheckAbort[Check[Get[pcVisioSource]; True, False], False] =!= True ||
   ! AssociationQ[pcValidation] || ! TrueQ[pcValidation["GraphicsConstructed"]], Exit[1]];

pcVisioJ = {pcQSwitch, pcFTriple};
pcVisioR = {pcQMax, pcFixedB + pcQMax/2};
pcVisioTop = {pcQSwitch, pcFMax};
pcVisioData = <|
  "qMax" -> pcQMax, "fMax" -> pcFMax, "triplePoint" -> pcVisioJ,
  "regions" -> <|
    "A" -> {{0, 0}, pcVisioJ, pcVisioTop, {0, pcFMax}},
    "B" -> {pcVisioJ, pcVisioR, {pcQMax, pcFMax}, pcVisioTop},
    "C" -> {{0, 0}, {pcQMax, 0}, pcVisioR, pcVisioJ}|>,
  "boundaries" -> <|"AC" -> {{0, 0}, pcVisioJ},
    "BC" -> {pcVisioJ, pcVisioR}, "AB" -> {pcVisioJ, pcVisioTop}|>
|>;
If[Export[pcVisioOutput, pcVisioData /. r_Rational :> N[r], "RawJSON"] === $Failed, Exit[1]];
Print["Exported geometry.json"];
