
# Cran Packages Parser

This ruby program is that indexes all avialable Packages from `http://cran.r-project.org/src/contrib/PACKAGES.gz`.

There are three parts of this program listend below

- Parser Class
- Scheduler 
- API   

# Parser Class  
This ruby program is that indexes all avialable Packages from `http://cran.r-project.org/src/contrib/PACKAGES.gz`. It will parse the given packages and check if they have already been parsed. In case a package have been parsed for information it will not be parsed again. 

This check is based on an assumption that md5 checksum will update in case the package is udpated. 

# Scheduler
Whn the Scheduler is started it runs parser job every 1 day, when it's started it parses the packages once and then repeats the job after 1 day, until it's killed mannually.

# API
API class is to check indexed packages, there are following routes available:
- `/packages`
- '/packages/:package_name/:version`

# How to run 
Dependencies:
- `ruby 2.7.5p203`
- `Bundler version 2.2.33`


First install the dependencies using:

`bundle install`

To start the Scheduler run:

`./schedule.rb`

in case perimssion is to granted for execution use the following command:

`chmod +x schedule.rb`

To run the API use:

`rackup`

and access the api at:

`http://localhost:9292/packages`

`http://localhost:9292/packages/A3/1.0.0`


# Testing

To run tests use 

`rspec`

and for checking for any changes in code quality after updating , run:

`rubocop`