# IRS527

This is a very basic Ruby library that parses the full text file containing all records from [Section 527 Political Organizations](http://www.irs.gov/Charities-&-Non-Profits/Political-Organizations/Political-Organization-Filing-and-Disclosure) as filed with the Internal Revenue Service.

Literally all it does it accept a path to the full file (which contains multiple types of records), reads it and creates four separate text pipe-delimited text files, one for each of:

	1. Registrations (8871.txt)
	2. Filings (8872.txt)
	3. Receipts (skeda.txt)
	4. Expenditures (skedb.txt)

Other files could be created based on additional record types.

## Installation

Add this line to your application's Gemfile:

    gem 'irs527'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install irs527

## Usage

First, [download the full data file](http://forms.irs.gov/app/pod/dataDownload/fullData) from the IRS, and unzip it. Alternatively, you could use the CLI command (mentioned below this) or in Ruby

```ruby
  Irs527::Utility.retrieve_data("PATH/TO/FILE")
  # generate the index file:
  Irs527::Utility.generate_index("PATH/TO/DATA/FILE", "PATH/TO/CSV\_FILE")
  # Please keep in mind the location of the index file
```

To use in Ruby:

```ruby
  require 'irs527'

  form_list = Irs527::FormList.load("PATH/TO/CSV", "PATH/TO/DATA/FILE")

  # if you have an EIN in mind, you can load the Query object associated with the forms by calling:
  form_list.query(ein)
  # If you don't know the EIN, but might have an idea of the name, pass in Regex or a String:
  result = form_list.find_by_name("Arizona")

  result # => [{name: Arizona Title Loan Association Political Action Committee}, ein: 471309553}, ...]
```

The `Query` object contains a variety of methods that directly access the form objects tied within for that organization.

To grab the most recent non amended 8872 form:

```ruby
  query = form_list.query(ein)
  query.non_amended # => [Irs527::Form8872Blahblah, ...]
```

## CLI

A command line interface is included in this gem. After downloading the file and creating the index csv, you can start querying for information straight from the command line.

First, to download:

    $ irs527 download <PATH>

To generate the index file, enter in the path of the extracted text file first followed by the name and path of the index file that will be created:

    $ irs527 generate <PATH/TO/DATA_FILE> <PATH/TO/NAME_OF_CSV_FILE>

Keep note of the name you give the csv file, as it will be required for other CLI commands.

If you have an EIN number already and would like to search it, do the following:

    $ irs527 summary <path/to/csv> --ein 371147621

```plaintext
  Name: AFSCME ILLINOIS POLITICAL ACTION COMMITTEE, EIN: 371147621
  Purpose: provide political contributions to candidates
  8871 forms: 1
  8872 forms: 0
  Contributions: 0.0
  Expenditures: 0.0
  Founding Date: 2012-06-01
  Last Updated: 2012-06-01
```

If you don't know the EIN but would like to search by name:

    $ irs527 summary <path/to/csv> --name "Bonnie Huy"

```plaintext
  Name: Bonnie Huy for State Representative, EIN: 481248542
  Purpose: Political Election Campaign for State Representative
  8871 forms: 1
  8872 forms: 0
  Contributions: 0.0
  Expenditures: 0.0
  Founding Date: 2002-07-06
  Last Updated: 2002-07-06
```

This will return a list if no exact match can be found.

Additionally, if you wish to narrow down the search by the type of form, either 8871 or 8872, add it as a final argument: `form_<TYPE>`.


## Contributing

1. Fork it ( http://github.com/<my-github-username>/irs527/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
