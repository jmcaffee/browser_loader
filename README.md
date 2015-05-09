# BrowserLoader

BrowserLoader is a watir-webdriver based browser loader class. It provides
additional chromium configuration options.

After I re-created this functionality for the 3rd time, I decided to turn it
into a gem so updates could take place in one location rather than multiple
places.

While BrowserLoader provides configuration for Chromium, it can load Firefox
or IE if desired. At this time, default configurations are used when loading
Firefox or IE.

When running on a linux OS, BrowserLoader will start the system's version of
the browser; the executable returned by `which chromium-browser`. When running
on windows, if using Chromium, a path to the Chromium/Chrome executable must
be provided.

Rather than being a nuisance, providing the executable path allows you to use
an older version of chromium for your testing. This becomes valuable if you
consider the breaking changes automatic updates of the browser can cause.

For me, this was especially a problem on windows.

Current versions of Chromium can be found at [http://chromium.woolyss.com](http://chromium.woolyss.com)
and older versions can be downloaded from the `continous` repo maintained by
Google at [https://storage.googleapis.com/chromium-browser-continuous/index.html](https://storage.googleapis.com/chromium-browser-continuous/index.html).

When creating the browser object, BrowserLoader looks for an environment variable
named `BROWSER`. If it exists and is populated with a recognized value, Firefox
or IE will be started. By default, Chromium will be started.

Possible `BROWSER` values:

+ `ie`: Internet Explorer
+ `ff`: Firefox

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'browser_loader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install browser_loader

## Usage

You can use the BrowserLoader::Factory class directly in your code, or derive/
compose a class from it.

Using it stand-alone:

```ruby
require 'browser_loader'

# Set the user data (profile) directory
BrowserLoader::Factory.user_data_dir = '/tmp/chromium_user_data'

# Override the default timeout period (in seconds)
BrowserLoader::Factory.timeout = 360

# Configure and start the Chromium browser
browser = BrowserLoader::Factory.build

# Do something with browser...

```

Using it through composition:

```ruby
require 'browser_loader'

module MyModule

  def browser
    if @browser.nil?
      # Set the user data (profile) directory
      BrowserLoader::Factory.user_data_dir = '/tmp/chromium_user_data'

      # Override the default timeout period (in seconds)
      BrowserLoader::Factory.timeout = 360

      # Configure and start the Chromium browser
      @browser = BrowserLoader::Factory.build

      # Add an +at_exit+ proc to close the browser when the program exits.
      at_exit do
        @browser.close unless @browser.nil?
      end
    end
  end
end # module


class SomeClass
  include MyModule

  def goto_google
    browser.goto 'http://google.com'
  end
end # class

```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/browser_loader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
