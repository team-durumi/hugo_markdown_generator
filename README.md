# Hugo Markdown Handler
Hugo content frontmatter handling scripts written in Ruby.

## Content Metadata to JSON Template
This script creates JSON files that serve as a template for your front matters.

1. Clone the repo and create metameta.yml to include options for the script to run.
```
$ cd path/to/this/repo
$ cp metameta.yml.example metameta.yml
```

2. Fill in the options
```
# metameta.yml
base_directory: # where you want to run your script
remote_url: # remote url for files if you are storing them in cloud services
hugo_content_directory_name: # name of your hugo content folder

front_matters:
  index: # add list of metas you want to create for _index.md
    - lastmod
    - title
    - weight
    - type
  single: # add list of metas you want to create for filename.md
    - reference_code
    - date
    - draft
    - level_of_description
    - media_type
    - title
    - description
    - weight
    - modified_at
    - created_at
    - link
    - components
    - tags
    - creators
    - subjects
    - sources
    - venues
    - public_access_status
    - copyright_status
```

3. run the script.
```
$ ruby content_metadata_to_json_template.rb
```

## Front Matter JSON to YAML Markdown
This script fetches hugo frontmatter data in JSON format and generates YAML markdown at a desired destination.

1. Clone the repo and create markdown_options.yml to include options for the script to run.
```
$ cd path/to/this/repo
$ cp markdown_options.yml.example markdown_options.yml
```
2. Fill in the options
```
# markdown_options.yml
base_directory: # where you want to run your script
path_to_hugo_content: # path upto hugo CONTENT directory
hugo_content_directory_name: # name of your hugo content folder under hugo CONTENT directory

```
3. Run the Script.
```
$ ruby frontmatter_json_to_yaml_markdown.rb
```

_____________

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
$ ruby csv_converter.rb -f 'path/to/csv/file' -d 'directory/to/save/markdown' -t 'multiple taxonomy terms separated by space'
```
* use '-b' option to specify which rows convert to markdown.
```
$ ruby csv_converter.rb -f 'path/to/csv/file' -d 'directory/to/save/markdown' -b 'boolean_field' # this only creates markdown files for rows that have the boolean_field set to "TRUE".

```
* Does not (yet) create any directory structures of files or accommodate for the multiple lines of the csv cells.

## [Shell Script to Deleting Markdown Files Recursively](https://www.baeldung.com/linux/recursively-delete-files-with-extension)
```
$ cd path/to/hugo/content/items
$ find . -type f -name '*.md' -print # double-check things that would be deleted
$ find . -type f -name '*.md' -print -delete 
$ find . -type f -name '*.md' -print # confirm that you have deleted
```
