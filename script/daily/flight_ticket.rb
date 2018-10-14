require 'selenium-webdriver'
require 'rails'
require 'sqlite3'
require 'active_record'
require './app/service/data_fetch_service.rb'
require './app/models/application_record'
require './app/models/flight_ticket'
ActiveRecord::Base.establish_connection(
    :adapter=> "sqlite3",
    :host => "localhost",
    :database=> "db/development.sqlite3"
  )
service = DataFetchService::DataFetchService.new(180)
service.execute