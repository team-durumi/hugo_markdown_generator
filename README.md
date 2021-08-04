# Hugo Markdown Handler
Ruby Markdown Handler Script for Hugo Contents.

## Markdown Generator for Hugo Content.
* When hugo content exists locally. Make sure to specify hugo items directory.
```
$ cd path/to/this/repo
$ ruby markdown_generator.rb -d 'path/to/hugo/items'
```
* Specify remote url with option if hugo components are remotely stored.
```
$ cd path/to/this/repo
$ ruby markdown_generator.rb -d 'path/to/hugo/items' -r 'https://example.bucket.com/items_root' 
```

## [Shell Script to Deleting Markdown Files Recursively](https://www.baeldung.com/linux/recursively-delete-files-with-extension)
```
$ cd path/to/hugo/items
$ find . -type f -name '*.md' -print # double-check things that would be deleted
$ find . -type f -name '*.md' -print -delete 
$ find . -type f -name '*.md' -print # confirm that you have deleted
```
