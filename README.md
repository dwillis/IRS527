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

First, [download the full data file](http://forms.irs.gov/app/pod/dataDownload/fullData) from the IRS, and unzip it. Then pass the path to the text file like so:

```ruby
require 'irs527'
Irs527::TextParser.parse("PATH/TO/FullDataFile.txt")
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/irs527/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
