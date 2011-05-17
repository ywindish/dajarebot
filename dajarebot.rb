#!/usr/local/bin/ruby
# -*- coding: UTF-8 -*-
require 'rubygems'
require 'rubytter'
require 'oauth'
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
    @config = YAML.load(f.read)
  end

  def get_twitter
    token = OAuth::AccessToken.new(
      OAuth::Consumer.new(@config['consumer_key'], @config['consumer_secret'], :site => @config['api']),
      @config['access_token'],
      @config['access_token_secret']
    )
    return OAuthRubytter.new(token)
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
    puts Kconv.kconv(message, Kconv::UTF8)
    begin
      if @config['twitter_post']
        @twitter.update Kconv.kconv(message + @config['hash_tag'], Kconv::UTF8)
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

