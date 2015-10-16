require 'spec_helper'

describe BrowserLoader::Factory do

  let(:factory) { BrowserLoader::Factory }

  it "uses a default client" do
    expect(factory.client).to_not be nil
  end

  it "log level is 0 by default" do
    expect(factory.log_level).to eq 0
  end

  it "browser timeout is 60 seconds by default" do
    expect(factory.browser_timeout).to eq 60
  end

  it 'user_data_dir is test/chrome-data by default' do
    expect(factory.user_data_dir.end_with?('test/chrome-data')).to be true
  end

  it "disk_cache_dir is test/cache-data by default" do
    expect(factory.disk_cache_dir.end_with?('test/cache-data')).to be true
  end

  it "switches contain default values" do
    switches = factory.switches
    expect(switches).to include "--ignore-certificate-errors"
    expect(switches).to include "--disable-popup-blocking"
    expect(switches).to include "--disable-translate"
    expect(switches).to include "--no-first-run"

    log_level = "--log-level=#{factory.log_level}"
    data_dir = "--user-data-dir=#{factory.user_data_dir}"
    cache_dir = "--disk-cache-dir=#{factory.disk_cache_dir}"
    expect(switches).to include log_level
    expect(switches).to include data_dir
    expect(switches).to include cache_dir
  end

  it "switches contain proxy string if configured" do
    port = '123'
    ENV['BROWSER_PROXY_PORT'] = port
    proxy_string = "--proxy-server=socks://localhost:#{port}"

    # Clear out the switches so they're regenerated.
    factory.reset_switches
    switches = factory.switches

    expect(switches).to include proxy_string

    # Clear out the switches so they're clean for other tests
    factory.reset_switches
    ENV['BROWSER_PROXY_PORT'] = nil
  end

  it "starts chrome and browses to google" do
    browser = factory.build
    browser.goto "https://google.com"
    expect(browser.html).to include "searchform"
    browser.close
  end

  it "starts firefox and browses to google" do
    ENV['BROWSER'] = 'ff'
    browser = factory.build
    browser.goto "https://google.com"
    expect(browser.html).to include "searchform"
    browser.close
    ENV['BROWSER'] = nil
  end

  if Ktutils::OS.windows?
    it "starts IE and browses to google" do
      ENV['BROWSER'] = 'ie'
      browser = factory.build
      browser.goto "https://google.com"
      expect(browser.html).to include "searchform"
      browser.close
      ENV['BROWSER'] = nil
    end
  end
end
