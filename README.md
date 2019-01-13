# CV Site

A Jekyll site for https://jameshale.net, based on the [Indigo theme](https://github.com/sergiokopplin/indigo) by Sérgio Kopplin.

## To Deploy:
```
bundle exec jekyll build
bundle exec htmlproofer ./_site --only-4xx
```

Upload generated assets in `./_site` to your hosting provider.
