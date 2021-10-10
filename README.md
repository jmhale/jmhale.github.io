# CV Site

A Jekyll site for [https://hale.dev](https://hale.dev), based on the [Indigo theme](https://github.com/sergiokopplin/indigo) by Sérgio Kopplin.

## To Test:
```
bundle exec jekyll build
bundle exec htmlproofer --url-ignore '/linkedin.com/' --assume_extension ./_site
```

## Run Locally:
```
bundle exec jekyll serve
```

Assets are generated in `./_site` and uploaded to S3 using Github Actions.
