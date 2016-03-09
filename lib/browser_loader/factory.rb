##############################################################################
# File:       factory.rb
# Purpose:    Browser configuration factory
#
# Author:     Jeff McAffee 10/16/2015
# Copyright:  Copyright (c) 2015, Jeff McAffee
#             All rights reserved. See LICENSE.txt for details.
# Website:    http://JeffMcAffee.com
#
# Some additional configuration is provided through the environment (variables).
#
#    BROWSER_PROXY_PORT:  when present, will be used to proxy connections.
#
#    BROWSER:             defaults to chrome/chromium when not set
#       ie: start Internet Explorer
#       ff: start Firefox
#
#
# Additional information:
#
#   https://sites.google.com/a/chromium.org/chromedriver/capabilities
#   http://peter.sh/experiments/chromium-command-line-switches/
#
##############################################################################

require 'watir-webdriver'
require 'ktutils'

module BrowserLoader
  class Factory

    def self.client
      # Client is explicitly instantiated so we can adjust the timeout period
      # or replace with a mock for testing.
      @@client ||= Selenium::WebDriver::Remote::Http::Default.new
    end

    def self.client= new_client
      @@client = new_client
    end

    ##
    # Timeout period for browser.
    # Defaults to 60 seconds
    #

    def self.browser_timeout
      @@browser_timeout ||= 60
    end

    def self.browser_timeout= timeout
      @@browser_timeout = timeout
    end

    ##
    # Directory to store profile data in
    # Defaults to test/chrome-data.
    #
    # Directory will be created if it doesn't exist. Note that it is a relative
    # path, so it is created relative to the current working directory.
    #
    # NOTE: The only way I've found to stop the EULA from being displayed is to
    # use the user-data-dir switch and point to a dir where chrome can put the
    # data indicating it (EULA) has already been accepted.
    #

    def self.user_data_dir
      @@user_data_dir ||= "test/chrome-data"

      # user_data_dir must be expanded to a full (absolute) path. A relative path
      # results in chromedriver failing to start.
      @@user_data_dir = File.expand_path(@@user_data_dir)
      #puts "*** user_data_dir location: #{@@user_data_dir}"

      # Create the data dir if it doesn't exist (or chromedriver fails to start).
      unless File.exists?(@@user_data_dir) and File.directory?(@@user_data_dir)
        FileUtils.makedirs @@user_data_dir
      end

      @@user_data_dir
    end

    def self.user_data_dir= dir
      @@user_data_dir = dir
    end

    ##
    # Directory to store cache data in
    # Defaults to test/cache-data.
    #
    # Directory will be deleted and recreated to ensure a clean cache.
    # Note thata the path is a relative path. It will be created relative
    # to the current working directory.
    #

    def self.disk_cache_dir
      @@disk_cache_dir ||= "test/cache-data"

      # Store chrome cache at test/cache-data.
      # We will wipe out this directory on each start to keep a clean cache.
      @@disk_cache_dir = File.expand_path(@@disk_cache_dir)
      # Delete the cache dir if it exists, then recreate it.
      if File.exists?(@@disk_cache_dir) and File.directory?(@@disk_cache_dir)
        FileUtils.rm_rf @@disk_cache_dir
      end
      FileUtils.makedirs @@disk_cache_dir

      @@disk_cache_dir
    end

    def self.disk_cache_dir= dir
      @@disk_cache_dir = dir
    end

    def self.log_level
      @@log_level ||= 0
    end

    ##
    # Set the browser logging level
    #
    # Sets the minimum log level.
    # Valid values are from 0 to 3:
    #   INFO = 0
    #   WARNING = 1
    #   LOG_ERROR = 2
    #   LOG_FATAL = 3
    #

    def self.log_level= level
      @@log_level = level
    end

    ##
    # Switches used to configure the chrome/chromium browser
    #
    # To modify/add switches:
    #   Factory.switches << "--some-other-switch=#{data}"
    #
    # See http://peter.sh/experiments/chromium-command-line-switches/ for a list of available switches.
    # See https://sites.google.com/a/chromium.org/chromedriver/capabilities for details on setting ChromeDriver caps.
    #
    # If BROWSER_PROXY_PORT environment variable is set to a port number,
    # the --proxy-server switch will be added.
    #
    # If you intend to override the user-data-dir, cache-data-dir or logging
    # level, do so before calling this method.
    #

    def self.switches
      @@switches ||= Array.new

      if @@switches.empty?
        # Default switches:
        #   ignore-certificate-errors:  Ignores certificate-related errors.
        #   disable-popup-blocking:     Disable pop-up blocking.
        #   disable-translate:          Allows disabling of translate from
        #                               the command line to assist with
        #                               automated browser testing.
        #   no-first-run:               Skip First Run tasks, whether or not
        #                               it's actually the First Run.
        @@switches = %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --no-first-run]
        @@switches << "--log-level=#{log_level}"
        @@switches << "--user-data-dir=#{user_data_dir}"
        @@switches << "--disk-cache-dir=#{disk_cache_dir}"

        proxy_port = ENV['BROWSER_PROXY_PORT']
        if proxy_port && ! proxy_port.empty?
          proxy_connection_string = "socks://localhost:#{proxy_port}"
          @@switches << "--proxy-server=#{proxy_connection_string}"
        end
      end

      @@switches
    end

    ##
    # Clear out all switches so they can be reconfigured
    #

    def self.reset_switches
      @@switches = Array.new
    end

    def self.download_dir
      @@download_dir ||= ""
    end

    ##
    # Set the download directory the browser will use
    #
    # NOTE: This is not currently working as of chromedriver v2.20
    # Until this works in chromedriver, the download_dir value should be
    # set to match the default download directory so things work as expected.
    #

    def self.download_dir= dir
      @@download_dir = dir
      @@download_dir.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
    end

    ##
    # Configure and return a browser object
    #

    def self.build
      # We must clear out any environmental proxy or Selenium fails
      # to connect to the local application.
      ENV['http_proxy'] = nil

      # No configuration is done if IE or Firefox browser is specified.
      env_browser = ENV['BROWSER']
      if env_browser
        if env_browser == "ie"
          return Watir::Browser.new :ie
        end

        if env_browser == "ff"
          return Watir::Browser.new :firefox
        end
      end

      # Specify chrome browser capabilities.
      caps = Selenium::WebDriver::Remote::Capabilities.chrome
      caps['chromeOptions'] = {'binary' => chromium_exe }
      unless download_dir.empty?
        prefs = {'download.default_directory' => download_dir }
        #caps['chromeOptions']['profile.download.prompt_for_download'] = false
        #caps['chromeOptions']['download.default_directory'] = download_dir
        caps['chromeOptions']['prefs' => prefs]
      end

      # Set the browser timeout. Default is 60 seconds.
      client.timeout = browser_timeout

      browser = Watir::Browser.new :chrome,
        :switches => switches,
        :http_client => client,
        :service_log_path => user_data_dir + '/chromedriver.out',
        :desired_capabilities => caps
    end

  private

    def self.chromium_exe
      if Ktutils::OS.windows?
        # Download from http://chromium.woolyss.com/
        chromium_exe = ENV["chrome_browser_path"]
        unless (! chromium_exe.nil? && ! chromium_exe.empty? && File.exist?(chromium_exe))
          raise "chrome_browser_path environment variable not set"
        end
        chromium_exe
      else
        chromium_exe = `which chromium-browser`.chomp
      end
    end
  end
end
