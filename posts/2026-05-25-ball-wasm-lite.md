---
title: ball wasm-lite 测试页面
date: 2026-05-25
tags: ball, wasm
description: ball 项目的 wasm-lite 2D / 3D 数学绘图测试页面。
---
ball 项目的 wasm-lite 数学绘图子集已经放到博客里了：

[打开 ball wasm-lite 测试页面](https://uuhan.github.io/ball-wasm-lite.html)

页面里可以直接输入公式并在浏览器中渲染 Canvas 图形，也包含一组覆盖当前 wasm-lite 子集的测试用例。

2026-05-29 更新：测试页已经补上 `plot3d` / 3D 绘图支持。现在顶部可以在 2D 和 3D 模式之间切换，3D 模式支持：

- 隐式曲面，例如 `x^2 + y^2 + z^2 = 1` 和 torus 方程；
- 参数曲线，例如 `x = t && y = t^2 && z = t^3`；
- camera 视角渲染，以及 `xy` / `yz` / `zx` 坐标平面投影。

这部分仍然是 wasm-lite 的浏览器子集：接口走 `render3dRgba`，用 f64 近似直接生成 RGBA buffer，适合网页里快速预览；原生 `ball plot3d` / MCP `plot3d` 仍是完整 3D 绘图路径。
