---
title: 添加Sundown作为Hakyll的编译器
date: 2017-08-29
tags: hakyll, sundown
---
[Hakyll](https://jaspervdj.be/hakyll/) 是一个静态博客工具库<a href="#fn1" id="fnref1" class="footnote-ref"><sup>1</sup></a>，得益于Haskell强大的生态和简洁健壮的代码风格，可以轻松地制作出功能强大的博客生成器。

[Sundown](https://github.com/vmg/sundown) 是C语言实现， 号称是 **忠于标准**，**快速**，**安全** 的, 用来渲染Markdown到Html代码的工具库。

Hakyll默认提供了很多编译器<a href="#fn2" id="fnref2" class="footnote-ref"><sup>2</sup></a>([copyFileCompiler](https://hackage.haskell.org/package/hakyll-4.9.8.0/docs/Hakyll-Core-File.html#v:copyFileCompiler), [pandocCompiler](https://hackage.haskell.org/package/hakyll-4.9.8.0/docs/Hakyll-Web-Pandoc.html#v:pandocCompiler)…), 本文通过将sundown作为编译器整合进hakyll来了解如何给hakyll添加自定义的编译函数。

我们需要以下的函数：

``` haskell
sundownCompiler :: Compiler (Item String)
```

Haskell的sundown绑定， 提供以下的函数用于渲染Markdown文档:

``` haskell
renderHtml :: Extensions -> HtmlRenderMode -> Bool -> Maybe Int -> String -> String
```

所以在Hakyll项目中增加两个函数:

``` haskell
import Hakyll
import Text.Sundown.Html.String

sundownCompiler :: Compiler (Item String)
sundownCompiler =
    sundownCompilerWith allExtensions noHtmlModes True Nothing

sundownCompilerWith :: Extensions -> HtmlRenderMode -> Bool -> Maybe Int -> Compiler (Item String)
sundownCompilerWith ext mode bool n =
    getResourceBody -- Compiler (Item String)
        >>= pure . readerHtml ext mode bool n . itemBody
        >>= makeItem
```

主要是使用 getResourceBody, makeItem 作为Hakyll内容的流入和流出， 中间的过程来做文档的渲染。

------------------------------------------------------------------------

1.  <div id="fn1">

    不同于jekyll, hexo之类的静态博客生成器，Hakyll是用来制作这类工具的工具库。<a href="#fnref1" class="footnote-back">↩︎</a>

    </div>

2.  <div id="fn2">

    签名为: compiler :: Compiler (Item a)<a href="#fnref2" class="footnote-back">↩︎</a>

    </div>
