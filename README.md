# Hugo Markdown Handler
Ruby Markdown Handler Script for Hugo Contents.

## Markdown Generator for Specfic Hugo Content.
* When hugo content exists locally. Make sure to specify hugo items directory.
```
$ cd path/to/this/repo
$ ruby markdown_generator.rb -b 'path/to/hugo/content/items'
```
* Specify remote url with option if hugo components are remotely stored.
```
$ cd path/to/this/repo
$ ruby markdown_generator.rb -b 'path/to/hugo/content/items' -r 'https://example.bucket.com/items_root'
```
* Or Specify hugo contents directory name if hugo components are locally stored.
```
$ cd path/to/this/repo
$ ruby markdown_generator.rb -b 'path/to/hugo/content/items' -c 'blog'
```

## Markdown Generator using comma separated values.
```
$ cd path/to/this/repo
$ ruby csv_converter.rb -f 'path/to/csv/file' -d 'path/to/where/you/want/markdown' -t 'multiple taxonomy terms separated by space'
```
* Does not (yet) create any directory structures of files or accommodate for the multiple lines of the csv cells.

## [Shell Script to Deleting Markdown Files Recursively](https://www.baeldung.com/linux/recursively-delete-files-with-extension)
```
$ cd path/to/hugo/content/items
$ find . -type f -name '*.md' -print # double-check things that would be deleted
$ find . -type f -name '*.md' -print -delete 
$ find . -type f -name '*.md' -print # confirm that you have deleted
```
