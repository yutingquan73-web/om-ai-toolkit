# 从 Mathematica 到带可编辑公式的 Visio 科研图

沿用[三工艺成本比较案例](../README.md)，完成模型计算、矢量交接、坐标标注和公式编辑的完整流程。Mathematica 计算区域和有效边界，PowerPoint 中转矢量图，Visio 添加坐标和刻度，MathType 保留可编辑公式。

## 先打开完成版

用 Windows 桌面版 Visio 打开 [完成版 R3](complete_R2/process_choice_finished_R3.vsdx)。两轴范围分别为 $q\in[0,12]$ 和 $f\in[0,24]$，三段边界在 $(6,15)$ 汇合。双击图中的 $f=5q/2$，可进入 MathType 编辑。建议另存一份练习副本。

| 文件 | 用途 |
| --- | --- |
| [模型坐标](complete_R2/geometry.json) | Mathematica 实际导出的区域顶点、边界和交点 |
| [SVG 底图](complete_R2/process_choice.svg) | 模型区域、有效边界、交点和工艺名称 |
| [PowerPoint 中转文件](complete_R2/process_choice_bridge.pptx) | 已插入 SVG 的单页文件 |
| [EMF 中转文件](complete_R2/process_choice_bridge.emf) | 由 PowerPoint 导出的矢量图 |
| [Visio 坐标完成版](complete_R2/process_choice_vector_R3.vsdx) | 独立坐标轴、刻度和模型底图组 |
| [Visio 公式完成版](complete_R2/process_choice_finished_R3.vsdx) | 在坐标完成版上加入一个 MathType 边界公式 |

坐标与普通文字可以单独编辑。模型底图位于锁定的 `ModelGeometry` 图层，坐标位于 `AxesAndLabels` 图层。改变研究参数时，应从模型重新生成底图和坐标。

## 从原始模型复现

需要 Windows 桌面版 Mathematica、PowerPoint、Visio，以及 MathType。已安装的软件应具有合法可用的许可。先复制整个三工艺案例作为练习副本，打开其中的 `process_choice.nb`。

在 Notebook 中新建输入单元，运行以下代码。它会重新计算原模型并写入一个新坐标文件。

```wolfram
pcVisioOutput = FileNameJoin[{NotebookDirectory[], "visio", "my_geometry.json"}];
Get[FileNameJoin[{NotebookDirectory[], "visio", "export_geometry.wl"}]];
pcValidation
```

基准应返回零网格差异、三项符号检查全部为 `True`，交点为 `{6,15}`。然后运行第二个输入单元，按这些坐标输出矢量底图。

```wolfram
pcVectorInput = pcVisioOutput;
pcVectorOutput = FileNameJoin[{NotebookDirectory[], "visio", "my_figure.svg"}];
Get[FileNameJoin[{NotebookDirectory[], "visio", "export_vector.wl"}]];
```

两个导出脚本遇到同名输出会停止。再次练习时使用新的文件名。若原模型计算出现错误，先排查原案例的验证结果。

从项目根目录打开 PowerShell，建立新的空输出目录，再运行中转脚本。路径对应上面生成的练习文件。

```powershell
New-Item -ItemType Directory .\my_vector
powershell -NoProfile -File .\examples\01-process-choice\visio\build_vector_bridge.ps1 -SvgPath .\examples\01-process-choice\visio\my_figure.svg -GeometryPath .\examples\01-process-choice\visio\my_geometry.json -OutputDirectory .\my_vector
```

打开 `my_vector/process_choice_vector.vsdx`，检查完整边框、两轴名称、所有刻度、三个区域和交点。基准交点在横轴范围中点、纵轴高度的 $15/24$ 处。并列归属以[原案例的判定条件](../README.md)为准。

本例的区域可用有限条直线精确描述，因此矢量底图使用 Mathematica 的 `Polygon` 和 `Line`，避免把 `RegionPlot` 的采样三角网格带入 Visio。曲线边界需要另行验证近似误差和矢量交接方式。

## 加入一个可编辑公式

在新生成的 Visio 文件中另存一个公式练习副本。使用“插入 → 对象”，选择本机已安装的 MathType 公式对象，新建公式并输入 `f=5q/2`，保存并返回 Visio。

把公式放在 A/C 上升边界的左上侧，避开边界与 A 标签。保存、关闭并重新打开 Visio 文件，再双击公式，确认仍能在 MathType 中编辑。这一步预计新增一个 MathType OLE 对象。[公式清单](formula_manifest.csv)记录了完成版的公式和核验状态。

## 已核验范围

基准模型在 Mathematica 13.3.1 中重新运行，2401 点网格零差异，三项符号检查及代表点检查通过。使用同一次计算导出的坐标和 SVG，已实际完成 PowerPoint 16.0 到 Visio 16.0 的中转，并复核修正脚本生成的画面。

完成版有完整坐标名称、范围、刻度与边框。模型底图含 10 个矢量子形状，坐标为 Visio 原生形状和文字。公式完成版保存重开后，已激活 MathType 编辑器核对 $f=5q/2$。文档属性中的作者和最后修改者为空，包内没有外部链接。

本轮完整流程核验覆盖固定费用为 12 的基准。固定费用为 16 的原模型已有历史计算验证，本轮重新计算触及时间预算，因此它在新增交接流程中的完整复现仍待核验。

## 转换说明

本机测试发现，将带完整坐标的图转成 Visio 原生形状时，会丢失左侧标注及部分边框。当前流程把模型底图与坐标标注分开交接，再依据同一份模型坐标在 Visio 中生成标注。

中转使用 PowerPoint 的 [Shape.Export](https://learn.microsoft.com/en-us/office/vba/api/powerpoint.shape.export) 和 Visio 的 [ConvertToGroup](https://learn.microsoft.com/en-us/office/vba/api/visio.shape.converttogroup)。
