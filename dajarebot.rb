#!/usr/local/bin/ruby
# -*- coding: UTF-8 -*-
require 'rubygems'
require 'twitter'
require 'kconv'
require 'yaml'

class Array
  def choice
    at( rand( size ) )
  end
end

class DajareBot

  def initialize
    @config = load_config
    @twitter = get_twitter
    load
  end

  def here_path(file)
    File.expand_path(File.dirname(__FILE__)) + '/' + file 
  end

  def load_config
    f = open(here_path('config.yml'))
    return YAML.load(f.read)
  end

  def get_twitter
    return Twitter::REST::Client.new do |config|
      config.consumer_key = @config['oauth']['consumer_key']
      config.consumer_secret = @config['oauth']['consumer_secret']
      config.access_token = @config['oauth']['access_token']
      config.access_token_secret = @config['oauth']['access_token_secret']
    end
  end

  def load
    @dajare_list = []
    open(here_path(@config['dajare_file_name'])) {|f|
      f.each {|line|
        line.chomp!
        @dajare_list.push line if line.size <= 140
      }
    }
  end

  def post(message)
    tweet = Kconv.kconv(message + ' ' + @config['hashtag'], Kconv::UTF8)
    puts tweet
    begin
      if @config['twitter_post']
        @twitter.update tweet
      end
    rescue => e
      p e
    end
  end

  def run
    post(@dajare_list.choice)
  end
end

DajareBot.new.run

