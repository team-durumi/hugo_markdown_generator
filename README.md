# Hugo Markdown Handler
Hugo content frontmatter handling scripts written in Ruby.

1. Create Front Matter Markdown from Content Directory Structure
2. Create Front Matter Markdown from CSV.

## Create Front Matter Markdown Template from the Content Directory Structure
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
$ ruby directory_structure_to_markdown.rb
```

4. Move Markdown Files in the Current Directory Structure to Hugo Contents Folder

[Shell Command to moving only markdown files from one directory to another.](https://ostechnix.com/copy-specific-file-types-while-keeping-directory-structure-in-linux/)
```
$ rsync -a -m --include '*/' --include '*.md' --exclude '*' path/from/ path/to/hugo/content/
```

## Generate Markdown Template using CSV.
```
$ cd path/to/this/repo
$ ruby csv_converter.rb -f 'path/to/csv/file' -d 'directory/to/save/markdown' -t 'multiple taxonomy terms separated by space'
```
* use '-b' option to specify which rows convert to markdown.
```
$ ruby csv_converter.rb -f 'path/to/csv/file' -d 'directory/to/save/markdown' -b 'boolean_field' # this only creates markdown files for rows that have the boolean_field set to "TRUE".

```
* Does not (yet) create any directory structures of files or accommodate for the multiple lines of the csv cells.

________________
## [Shell Command to Deleting Markdown Files Recursively](https://www.baeldung.com/linux/recursively-delete-files-with-extension)
```
$ cd path/to/hugo/content/items
$ find . -type f -name '*.md' -print # double-check things that would be deleted
$ find . -type f -name '*.md' -print -delete 
$ find . -type f -name '*.md' -print # confirm that you have deleted
```
