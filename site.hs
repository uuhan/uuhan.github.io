{-# LANGUAGE OverloadedStrings #-}

import Data.List (intercalate)
import Hakyll
import System.FilePath (splitDirectories, takeBaseName, (</>), (<.>))
import Text.Pandoc.Options (WriterOptions, writerTableOfContents)

main :: IO ()
main = hakyll $ do
    match "assets/**" $ do
        route idRoute
        compile copyFileCompiler

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler

    tags <- buildTags "posts/*" (fromCapture "tags/*/index.html")

    tagsRules tags $ \tag pattern' -> do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern'
            let ctx =
                    constField "title" ("文章分类: " ++ tag)
                        <> listField "posts" (postCtx tags) (return posts)
                        <> siteCtx
            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["tags/index.html"] $ do
        route idRoute
        compile $ do
            let ctx =
                    constField "title" "分类"
                        <> tagCloudField "tagcloud" 80 200 tags
                        <> siteCtx
            makeItem ""
                >>= loadAndApplyTemplate "templates/tags.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "posts/*" $ do
        route postRoute
        compile $
            pandocCompilerWith defaultHakyllReaderOptions pandocOptions
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtx tags)
                >>= relativizeUrls

    match "pages/about.md" $ do
        route $ constRoute "about.html"
        compile $
            pandocCompiler
                >>= loadAndApplyTemplate "templates/page.html" siteCtx
                >>= loadAndApplyTemplate "templates/default.html" siteCtx
                >>= relativizeUrls

    match "pages/ball-wasm-lite.html" $ do
        route $ constRoute "ball-wasm-lite.html"
        compile $ do
            let ctx = constField "title" "ball wasm-lite 测试" <> siteCtx
            getResourceBody
                >>= loadAndApplyTemplate "templates/page.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx =
                    constField "title" "归档"
                        <> listField "posts" (postCtx tags) (return posts)
                        <> siteCtx
            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["index.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx =
                    constField "title" "主页"
                        <> listField "posts" (postCtx tags) (return posts)
                        <> tagCloudField "tagcloud" 80 200 tags
                        <> siteCtx
            makeItem ""
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderAtom feedConfig (feedCtx tags) posts

    match "templates/*" $ compile templateBodyCompiler

pandocOptions :: WriterOptions
pandocOptions =
    defaultHakyllWriterOptions
        { writerTableOfContents = True
        }

postRoute :: Routes
postRoute = customRoute $ \identifier ->
    case splitSlug (takeBaseName $ toFilePath identifier) of
        Just (year, month, day, slug) -> year </> month </> day </> slug <.> "html"
        Nothing -> takeBaseName (toFilePath identifier) <.> "html"

splitSlug :: String -> Maybe (String, String, String, String)
splitSlug name =
    case splitOn '-' name of
        year : month : day : rest | not (null rest) ->
            Just (year, month, day, intercalate "-" rest)
        _ -> Nothing

splitOn :: Char -> String -> [String]
splitOn delimiter = go []
  where
    go current [] = [reverse current]
    go current (c : cs)
        | c == delimiter = reverse current : go [] cs
        | otherwise = go (c : current) cs

postCtx :: Tags -> Context String
postCtx tags =
    dateField "date" "%B %e, %Y"
        <> tagsField "tags" tags
        <> siteCtx

feedCtx :: Tags -> Context String
feedCtx tags =
    bodyField "description"
        <> postCtx tags

siteCtx :: Context String
siteCtx =
    constField "siteTitle" "凝聚层的上同调"
        <> constField "blogTitle" "数字人生"
        <> constField "authorName" "MinHui, Xu"
        <> constField "authorEmail" "xuminhui_jia@126.com"
        <> rootField
        <> defaultContext

rootField :: Context a
rootField = field "root" $ \item -> do
    route' <- getRoute (itemIdentifier item)
    pure $ maybe "./" routeToRoot route'

routeToRoot :: FilePath -> String
routeToRoot route' =
    case length (splitDirectories route') - 1 of
        n | n <= 0 -> "./"
        n -> concat (replicate n "../")

feedConfig :: FeedConfiguration
feedConfig =
    FeedConfiguration
        { feedTitle = "数字人生"
        , feedDescription = "This is uuhan's post on his blog."
        , feedAuthorName = "MinHui, Xu"
        , feedAuthorEmail = "xuminhui_jia@126.com"
        , feedRoot = "https://blog.uuhan.me"
        }
