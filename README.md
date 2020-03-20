# README
This is a ruby 2.6.5 based project. For installation of ruby and ruby env managers follow https://gorails.com/setup
 and install posgresql

## Intsall depndencies
```
gem install bundler -v 2.1.4
bundle
```

## Database Setup
```
rake db:create db:migrate
```

## Populate Data
```
rake db:seed
```
Note: This will create a table of applicants with 10000 records for a bigger search tree

## Drop Database
```
rake db:drop
```

## Run server
```
rails s
```

## To fetch applicant with matching substrings in text field
```
curl -i -H "Accept: application/json" -H "Content-Type: application/json" http://127.0.0.1:3000/search_text?limit=10&query=java
```
