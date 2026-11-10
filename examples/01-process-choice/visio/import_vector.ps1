[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$EmfPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [string]$GeometryPath,
    [string]$PreviewPath)
$ErrorActionPreference = 'Stop'
$EmfPath = (Resolve-Path -LiteralPath $EmfPath).Path
$OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (!$GeometryPath) { $GeometryPath = Join-Path $PSScriptRoot 'complete_R2/geometry.json' }
$geometry = Get-Content -LiteralPath $GeometryPath -Raw -Encoding UTF8 | ConvertFrom-Json
$qMax = [double]$geometry.qMax
$fMax = [double]$geometry.fMax
if ($qMax -le 0 -or $fMax -le 0) { throw 'The plot range must be positive.' }
if (Test-Path -LiteralPath $OutputPath) { throw 'Choose a new Visio output path.' }
if ($PreviewPath) {
    $PreviewPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PreviewPath)
    if (Test-Path -LiteralPath $PreviewPath) { throw 'Choose a new preview output path.' }
}
$app=$null
$doc=$null
try {
    $app=New-Object -ComObject Visio.InvisibleApp
    $doc=$app.Documents.Add('')
    $page=$doc.Pages.Item(1)
    $page.PageSheet.CellsU('PageWidth').FormulaU='10 in'
    $page.PageSheet.CellsU('PageHeight').FormulaU='7.5 in'
    $base=$page.Import($EmfPath)
    $base.ConvertToGroup()
    $base=$page.Shapes.Item(1)
    $base.NameU='MathematicaVectorBase'
    foreach ($child in $base.Shapes) { $child.CellsU('ResizeMode').FormulaU='2' }
    $plotLeft=1.2
    $plotBottom=1.0
    $plotWidth=8.0
    $plotHeight=16.0/3.0
    $base.CellsU('Width').ResultIU=$plotWidth
    $base.CellsU('Height').ResultIU=$plotHeight
    $base.CellsU('PinX').ResultIU=$plotLeft+$plotWidth/2
    $base.CellsU('PinY').ResultIU=$plotBottom+$plotHeight/2
    $layer=$page.Layers.Add('ModelGeometry')
    $layer.Add($base,0)
    $layer.CellsC(6).FormulaU='1'
    $annotationLayer=$page.Layers.Add('AxesAndLabels')
    $frame=$page.DrawRectangle($plotLeft,$plotBottom,$plotLeft+$plotWidth,$plotBottom+$plotHeight)
    $frame.NameU='CoordinateFrame'
    $frame.CellsU('FillPattern').FormulaU='0'
    $frame.CellsU('LineWeight').FormulaU='0.7 pt'
    $annotationLayer.Add($frame,0)
    function Add-AxisText([string]$name,[string]$text,[double]$x,[double]$y,[double]$width=0.5) {
        $shape=$page.DrawRectangle($x-$width/2,$y-0.12,$x+$width/2,$y+0.12)
        $shape.NameU=$name
        $shape.Text=$text
        $shape.CellsU('FillPattern').FormulaU='0'
        $shape.CellsU('LinePattern').FormulaU='0'
        $shape.CellsU('Char.Size').FormulaU='10 pt'
        $annotationLayer.Add($shape,0)
        return $shape
    }
    foreach ($i in 0..6) {
        $x=$plotLeft+$plotWidth*$i/6
        $y=$plotBottom+$plotHeight*$i/6
        $q=($qMax*$i/6).ToString('0.##',[Globalization.CultureInfo]::InvariantCulture)
        $f=($fMax*$i/6).ToString('0.##',[Globalization.CultureInfo]::InvariantCulture)
        $null=Add-AxisText "QTick$i" $q $x ($plotBottom-0.22)
        $null=Add-AxisText "FTick$i" $f ($plotLeft-0.3) $y
        foreach ($bounds in @(@($x,$plotBottom,$x,($plotBottom+0.055)),@($plotLeft,$y,($plotLeft+0.055),$y))) {
            $tick=$page.DrawLine($bounds[0],$bounds[1],$bounds[2],$bounds[3])
            $annotationLayer.Add($tick,0)
        }
    }
    $null=Add-AxisText 'QAxisLabel' 'Quantity q' ($plotLeft+$plotWidth/2) 0.4 2.0
    $yLabel=Add-AxisText 'FAxisLabel' 'Fixed cost f' 0.35 ($plotBottom+$plotHeight/2) 2.0
    $yLabel.CellsU('Angle').FormulaU='90 deg'
    $doc.RemovePersonalInformation=$true
    $doc.SaveAs($OutputPath)
    if ($PreviewPath) {$page.Export($PreviewPath)}
    Write-Output "Saved vector group containing $($base.Shapes.Count) child shapes."
} finally {
    if ($doc) {$doc.Saved=$true;$doc.Close()}
    if ($app) {$app.Quit()}
}
