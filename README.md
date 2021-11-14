# Hugo Markdown Handler
Hugo content [Front Matter](https://gohugo.io/content-management/front-matter/) handling scripts written in Ruby.

Scripts in this repo does one of two things.
1. [Generate Front Matter Markdown within the desired content directory based on settings declared in front_matter_schema.yml.] (## Generate Front Matter Markdown from front_matter_schema.yml)
2. [Generate Front Matter Markdown within the desired content directory by importing CSV file with declared metadata.] (## Generate Markdown Template using CSV)

## Generate Front Matter Markdown from front_matter_schema.yml
This script creates front matter markdown files.
1. Clone the repo and create front_matter_schema.yml.
```
$ cd path/to/this/repo
$ cp front_matter_schema.yml.example front_matter_schema.yml
```

2. Define metadata keys in front_matter_schema.yml.
```
# front_matter_schema.yml
index: # for creating _index.md
  string: # for front matters with single values
    - lastmod
    - title
    - weight
    - type
  array:  # for front matters with multiple array values
    -
single: # for creating single pages (https://gohugo.io/content-management/organization/#single-pages-in-sections)
  string: # for front matters with single values
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
    - public_access_status
    - copyright_status
  array:  # for front matters with multiple array values
    - components
    - tags
    - creators
    - subjects
    - sources
    - venues
```
3. run the script with options

```
$ ruby  directory_structure_to_markdown.rb \
        --base '/path/to/hugo/section' \
```
* 파일명에 메타데이터를 넣어서 front matter를 생성하려고 하는 경우.

```
$ ruby  directory_structure_to_markdown.rb \
        --base '/path/to/hugo/section' \
        --which parent 
        # 특정 파일의 프론트 매터 생성시, 그 파일의 parent의 파일명을 참고하여 프론트매터를 생성. vs 'self' 선택시에는 스스로의 파일명 참고
```

4. Move Markdown Files in the content directory to Hugo Contents Folder if Hugo Contents are stored remotely.

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
