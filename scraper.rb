#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  # raw = open(url).read.force_encoding('euc-kr').encode('utf-8')
  # Nokogiri::HTML(raw)
  Nokogiri::HTML(open(url).read, nil, 'euc-kr')
end

def scrape_list(url)
  noko = noko_for(url)
  box = noko.css('#contentSize')
  box.xpath('text()').drop(1).each_with_index do |line, i|
    matched = line.text.tidy.match(/제(.*?)호 (.*?)선거구 ?(.*?)$/) or binding.pry
    got = matched.captures
    data = {
      id:     got[0],
      name:   got[2],
      area:   got[1],
      term:   13,
      source: url,
    }
    # puts data
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://www.dailynk.com/korean/read.php?num=102886&cataId=nk00100')
