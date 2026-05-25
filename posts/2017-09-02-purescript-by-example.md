---
title: PureScript入门教程
date: 2017-09-02
tags: 翻译, purescript
---
### 1. 介绍

#### 1.1 函数式JavaScript

函数式编程技术已经在JavaScript中出现有一段时间了:

- 例如[UnderScoreJS](http://underscorejs.org/)之类的库允许开发者使用经测试被信任的，诸如 **map**, **filter** 和 **reduce** 之类的函数的组合， 将小段的程序拼接成更大的程序:

``` javascript
var sumOfPrimes =
      _.chain(_.range(1000))
       .filter(isPrime)
       .reduce(function(x, y) {
          return x + y;
       })
       .value();
```

- NodeJS中的异步编程大量依赖作为第一类对象的 **函数** 定义回调:

``` javascript
require('fs').readFile(sourceFile, function (error, data) {
  if (!error) {
        require('fs').writeFile(deskFile, data, function (error) {
          if (!error) {
            console.log("File copied");
          }
        });
  }
});
```

- 诸如 [React](http://facebook.github.io/react/) 和 [virtual-dom](https://github.com/Matt-Esch/virtual-dom) 之类的库将视图模拟为应用状态的函数.

函数激活了一种能够带来极大生产效率的抽象形式。然而，JavaScript中的函数式编程也有它的缺点: JavaScript是冗长的，未类型化的，并且缺少强有力的抽象形式。随意的JavaScript代码同样让等式推导变得十分困难。

PureScript 是一门致力于解决这些问题的编程语言。 它拥有轻量的语法, 允许我们写出富有表达力的代码的同时保持代码清晰和可读。 它使用了丰富的类型系统来支撑其强力的抽象能力。 它也同时能生成快速，能被理解的代码，这一点当需要和JavaScript或其他编译到JavaScript的语言相互操作的时候显得很重要。总而言之，我希望能让你相信，PureScript在纯函数式编程理论上的威力和JavaScript灵巧的编程风格之间的平衡点。

#### 1.2 类型和类型推导

关于静态类型语言和动态类型语言的争论已经是老生常谈的话题了。 PureScript是一种 *静态类型* 的语言，即，一个正确程序可以被编译器附上一个表明它的行为的类型。 反之，不能被确定其类型的程序是 *不正确的程序*，同时也会被编译器拒绝。 在PureScript中，不像动态类型语言，类型只存在于 *编译期*，不会在运行时表现。

需要注意的是，PureScript中的类型和你在其他语言，如Java或C#中的类型不一样。 但是它们在某种意义上都都服务于同一个目的，PureScript的类型受像ML和Haskell之类的语言启发。 PureScript的类型是富有表现力的，它允许开发者给他们的程序下很强的断言。 最重要的是，PureScript的类型系统支持 *类型推导* - 它比其他的语言需要更少的显式类型标注，使得类型系统成为一个 *工具*而不是编程的阻力。 举一个简单的例子，下面的代码定义了一个 *数字*，但是并没有在代码的任何其他地方提到它是 *Number* 类型的:

``` haskell
iAmANumber =
    let square x = x * x
    in square 42.0
```

一个更加复杂的例子演示了类型正确在没有类型注释的时候也能被保证，甚至存在 *编译器都不识别* 的类型:

``` haskell
iterate f 0 x = x
iterate f n x = iterate f (n - 1) (f x)
```

这里，*x* 的类型是未知的，但是编译器还是可以验证 *iterate* 遵守了类型系统的规则，不管 *x* 具有什么类型。

在本书中，我将尝试使你相信（或使你再次确信），静态类型不仅是让你相信你的程序正确的方式，同时也是帮助开发正确程序的手段。<a href="#fn1" id="fnref1" class="footnote-ref"><sup>1</sup></a> 不使用最简单的抽象的话，重构一段大型的JavaScript代码可能是很困难的，但是当一个富有表达能力的类型系统加上一个类型检查器却能让重构变成令人享受的交互经历。

另外，类型系统提供的安全保障同时也使更高级的抽象形式成为可能。事实上，PureScript提供了一个强力的基于类型驱动的抽象方式: *类型类*，这在函数式编程语言Haskell中很流行。

#### 1.3 多语言的网络编程<a href="#fn2" id="fnref2" class="footnote-ref"><sup>2</sup></a>

函数式编程有它成功的故事 - 它取得成功的应用领域：譬如数据分析，解析，编译器实现，泛型编程，并行编程。

使用像PureScript这样的函数式编程语言来开发端到端的应用是可能的。 PureScript通过赋予Javascript语言的值和函数对应的类型，然后在PureScript代码中使用这些函数，提供了导入现存的JavaScript库的能力。 我们将在本书的后面看到这种方法。

尽管PureScript其中一个能力是和其他编译到JavaScript的语言交互, 你也可以在你的项目里面部分使用PureScript，同时使用一种或多种其他的语言写剩下的JavaScript代码。

这里有一些例子：

- 核心的逻辑使用PureScript写，用户界面使用JavaScript。
- 使用JavaScript或者编译到JS的语言写的应用，使用PureScript写测试。
- 使用PureScript做用户界面自动化测试。

在本书中，我们将关注如何使用PureScript解决小型的问题。解决方法可以被集成进更大的应用中去，同时我们也将看看如何从JavaScript调用PureScript或者反之。

#### 1.4 准备

本书需要用到的软件很少：第一章将会指导你从头建立开发环境，我们将使用的工具在绝大多数现代操作系统中都是能获取到的。

PureScript编译器本身可以下载二进制发布的，也可以在任何安装有最新的GHC Haskell编译器的操作系统上编译源码安装，我们将在下一章节中介绍。

本书代码使用 **0.11.\*** 版本的PureScript编译。

#### 1.5 关于读者

我将假设你熟悉JavaScript的基本用法。如果你希望做一些符合自己需求的定制，熟悉任何JavaScript生态常用的工具，比如NPM和Gulp，都很有帮助，但是这些知识都不是必须的。

不需要提前了解函数式编程的知识，但是多多益善。我们会从每个实例中得出新的概念，所以你需要能够对我们将使用的一些函数式编程的概念形成一些直觉上的知识。

对Haskell编程语言熟悉的读者，将会看到大量相同的概念和语法，因为PureScript很大程度上受Haskell影响。 但是这些读者应该意识到这两者之间存在着很多重要的差异性。 不必要总是试图将一种语言的想法套到另一种语言上，尽管这里很多的概念在Haskell中都能得到一些解释。

#### 1.6 如何阅读本书

本书的章节内容大部分都是不需要引用外部资源的。对于没有函数式编程经验的初学者也能得到很好的建议，但是需要按照顺序阅读。 开始的几章是接下来章节的基础。对于有丰富函数式编程经验（特别是有强类型语言比如ML和Haskell经验的读者），可以跳过这些章节。

每一章都会有一个单独的实例，作为接下来介绍新的概念的动机。每一章的代码都能从本书的 [GitHub仓库](https://github.com/paf31/purescript-book) 中获取。 一些章节会包含从代码库摘取的代码片段，但是为了有完整的理解，你应该跟着材料阅读代码库里面完整的代码。 更长的章节会包含更短的代码片段，你可以在交互模式的PSCi中测试一下验证你的理解。

代码例子会用等宽字体显示，比如：

``` haskell
module Example where

import Control.Monad.Eff.Console (log)

main = log "Hello, World!"
```

需要在命令行输入的命令，会带上一个前置的 \$ 符号：

``` shell
$ pulp build
```

通常情况下，这些命令都是针对 Linux/Mac OS 用户的，Windows 用户可能需要做一些小调整比如改变文件分隔符，或者替换 Windows等价的命令行内置功能。

需要在 PSCi 交互模式输入的命令会前置一个尖括号：

``` shell
> 1 + 2
3
```

每一章都会包含习题，会标注它们的困难程度。强烈建议你在完全理解材料内容之后再去尝试做这些习题。

本书旨在为 PureScript 语言初学者做入门介绍，而不是那种给特定问题提供解答的参考书。 对于初学者，本书应该是一个有趣的挑战，如果你阅读了材料，尝试了习题，最重要的是尝试写了一些你自己的代码，那么你将会得到最大的收获。

#### 1.7 获取帮助

如果你被任何知识点卡住了，这里有很多网上资源能帮你学习 PureScript：

- PureScript IRC频道是你可以交流问题最好的去处。将你的 IRC客户端 指到 irc.freenode.net，加入 \#purescript 频道。
- [PureScript网站](http://purescript.org/) 包含了一些代码，视频，和其他面向初学者的学习资料的链接。
- [PureScript文档](https://github.com/purescript/documentation) 收集了 PureScript 开发者和用户写的涵盖大量主题的文章和示例。
- [Try PureScript!](http://try.purescript.org/) 是一个允许用户在线编译 PureScript 代码的网站，同时也包含了一些简单的代码示例。
- [Pursuit](http://pursuit.purescript.org/) 是一个检索 PureScript 类型和函数的数据库。

如果你愿意通过阅读示例来学习， *purescript*, *purescript-node*, *purescript-contrib* GitHub组织包含了大量的 PureScript 示例代码。

#### 1.8 关于作者

我是 PureScript编译器 最初的开发者。居住在 Los Angeles, Californiz, 很早就开始在8位个人电脑(Amstrad CPC)上开始BASIC编程。 之后专职用很多编程语言工作（包括Java，Scala，C#，F#，Haskell 和 PureScript）。

在我开始职业生涯不久，我开始喜欢上函数式编程和它与数学的联系，并且十分享受用 Haskell 学习函数式概念。

我开始 PureScript编译器 相关的工作，主要是受 JavaScript 体验的影响。 我发现自己一直使用从 Haskell 之类的语言中获取的函数式编程技术，但是更加希望在一个 基础<a href="#fn3" id="fnref3" class="footnote-ref"><sup>3</sup></a> 的场合去使用它们。 那时的解决办法是在保留语义的前提下，将 Haskell 编译到 JavaScript（这类尝试有 Fay，Haste，GHCJS），但是我更感兴趣的是是否可以通过另一面处理这个问题 - 尝试保留 JavaScript 的语义，同时享受像 Haskell 之类语言的语法和类型系统。

我有一个 [博客](http://blog.functorial.com/)，也可以在 [Twitter](http://twitter.com/paf31) 上联系我

#### 1.9 感谢

我想感谢所有帮助 PureScript 进步的贡献者。 如果没有这些在编译器，工具，库，文档和测试上的集体的努力，这个项目一定会失败。

PureScript 的出现在本书封面的 logo 由 Gareth Hughes创作，基于 [Creative Commons Attribution 4.0 license](https://creativecommons.org/licenses/by/4.0/) 条款，十分感谢能在这里使用。

最后，我想感谢所有给了我关于本书反馈和更正的人。

### 2. 开始

------------------------------------------------------------------------

1.  <div id="fn1">

    原文是: … not only a means of gaining confidence in the correctness of your programs, but also an aid to development in their own right.<a href="#fnref1" class="footnote-back">↩︎</a>

    </div>

2.  <div id="fn2">

    原文是: Polyglot Web Programming<a href="#fnref2" class="footnote-back">↩︎</a>

    </div>

3.  <div id="fn3">

    原文是: principled environment, 结合下文应该是 基础性的，一般性，更通用的场合<a href="#fnref3" class="footnote-back">↩︎</a>

    </div>
