# Hugo Markdown Handler
Ruby Markdown Handler Script for Hugo

## Markdown Generator
```
cd path/to/this/repo
ruby markdown_generator.rb -d 'path/to/hugo/items'
```

## [Deleting Markdown Files Recursively](https://www.baeldung.com/linux/recursively-delete-files-with-extension)
```
$ cd path/to/hugo/items
$ find . -type f -name '*.md' -print -delete
```
