# uuhan

Recovered Hakyll source for the generated site.

The generated HTML was the only available source, so posts under `posts/`
are best-effort Markdown conversions from the published pages. Static assets
are copied verbatim.

Useful commands:

```bash
cabal run site -- build
cabal run site -- watch
```

Deployment:

The repository is configured for GitHub Pages deployment through GitHub
Actions. Pushes to the default branch build the Hakyll site into `_site` and
deploy that directory with the official Pages artifact flow. Generated files
are not committed to the repository.

In the GitHub repository settings, set:

- Settings -> Pages -> Build and deployment -> Source: `GitHub Actions`

The recovered routing preserves the published post URLs, tag pages, archive,
about page, and Atom feed.
