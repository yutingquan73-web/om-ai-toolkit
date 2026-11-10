[CmdletBinding()]
param([string]$SvgPath, [string]$OutputDirectory, [string]$GeometryPath, [string]$PreviewPath)

$ErrorActionPreference = 'Stop'
if (!$SvgPath) { $SvgPath = Join-Path $PSScriptRoot 'complete_R2/process_choice.svg' }
if (!$OutputDirectory) { $OutputDirectory = $PSScriptRoot }
$SvgPath = (Resolve-Path -LiteralPath $SvgPath).Path
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$pptx = Join-Path $OutputDirectory 'process_choice_bridge.pptx'
$emf = Join-Path $OutputDirectory 'process_choice_bridge.emf'
$vsdx = Join-Path $OutputDirectory 'process_choice_vector.vsdx'
foreach ($path in @($pptx, $emf, $vsdx)) {
    if (Test-Path -LiteralPath $path) { throw "Output already exists: $path" }
}

$presentation = $null
try {
    $powerpoint = New-Object -ComObject PowerPoint.Application
    $presentation = $powerpoint.Presentations.Add(0)
    $presentation.PageSetup.SlideWidth = 720
    $presentation.PageSetup.SlideHeight = 504
    $slide = $presentation.Slides.Add(1, 12)
    $figure = $slide.Shapes.AddPicture($SvgPath, 0, -1, 36, 24, 648, -1)
    $figure.Name = 'MathematicaVectorBase'
    $presentation.RemovePersonalInformation = -1
    $presentation.SaveAs($pptx, 24)
    $figure.Export($emf, 5)
    $presentation.Close()
    $presentation = $null

    & (Join-Path $PSScriptRoot 'import_vector.ps1') -EmfPath $emf -OutputPath $vsdx -GeometryPath $GeometryPath -PreviewPath $PreviewPath
} finally {
    if ($presentation) { $presentation.Saved = -1; $presentation.Close() }
}
