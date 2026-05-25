---
title: WebAssembly介绍
date: 2017-09-08
tags: 前端, webassembly
---
### 什么是WebAssembly<a href="#fn1" id="fnref1" class="footnote-ref"><sup>1</sup></a>?

WebAssembly是浏览器里的汇编语言，它本身有 **二进制** 和 **文本**<a href="#fn2" id="fnref2" class="footnote-ref"><sup>2</sup></a> 两种表达方式，类似于机器码和汇编代码。 同时很多通用编程语言，比如**C/C++**,**Rust**,**TypeScript**都可以编译到wasm。

wasm具有近乎原生的执行效率，所以在比较耗时的前端任务，比如 **WebGL** 动画，加解密，核心算法实现等方面可以带来一定的性能提升。 同时其二进制的文件格式，也能一定程度上起到保护前端代码的作用<a href="#fn3" id="fnref3" class="footnote-ref"><sup>3</sup></a>。

处于安全方面的考虑，wasm中的代码访问的内存空间比较特殊。 代码不直接访问系统分配的内存，而是映射到js的一个ArrayBuffer对象中。

### 如何使用WebAssembly?

最新的现代浏览器基本都支持<a href="#fn4" id="fnref4" class="footnote-ref"><sup>4</sup></a>。现在使用wasm需要以下的工具链：

1.  emscripten, 基于LLVM低级虚拟机，可以将llvm bytecode编译到wasm

2.  wabt, wasm二进制工具

3.  binaryen， 编译器和工具链基础包

由于wasm还处于实验阶段，其调用还需要依赖js。未来可能会引入浏览器原生的wasm支持。可以用以下方式调用wasm代码:

``` javascript
const memory = new WebAssembly.Memory({ initial: 256, maximum: 256});

fetch('some.wasm').then(response =>
  response.arrayBuffer()
).then(bytes => {

  var imports = {};
  imports.env = {};
  imports.env.STACKTOP = 0;
  imports.env.STACK_MAX = 100;
  imports.env.abortStackOverflow = function(e) { console.log('stack overflow: ', e)};
  imports.env.memory = memory // 代码内存空间
  imports.env.memoryBase = 0;
  imports.env.table = new WebAssembly.Table({ initial: 0, maximum: 0, element: 'anyfunc'});
  imports.env.tableBase = 0;

  return WebAssembly.instantiate(bytes, imports); // 初始化wasm代码

}).then(module => {

  exports = module.instance.exports; // 导出函数接口
  // 调用接口

})
```

### 演示实例

两个演示wasm使用的例子

------------------------------------------------------------------------

1.  <div id="fn1">

    维基百科: [WebAssembly](https://zh.wikipedia.org/wiki/WebAssembly)<a href="#fnref1" class="footnote-back">↩︎</a>

    </div>

2.  <div id="fn2">

    一种类似于lisp的 **s-表达式**，下面会提到<a href="#fnref2" class="footnote-back">↩︎</a>

    </div>

3.  <div id="fn3">

    二进制形式可以通过工具“反汇编”成s-表达式<a href="#fnref3" class="footnote-back">↩︎</a>

    </div>

4.  <div id="fn4">

    参考：http://caniuse.com/#feat=wasm<a href="#fnref4" class="footnote-back">↩︎</a>

    </div>
