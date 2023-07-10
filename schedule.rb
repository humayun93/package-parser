#!/usr/bin/env ruby
# frozen_string_literal: true

# this is schedule file that will run a job every day to parse the packages information

require 'rufus-scheduler'
require_relative 'app/lib/package_parser'

scheduler = Rufus::Scheduler.new

scheduler.every '1d', first_at: Time.now + 1 do
  puts "Running the job at #{Time.now}"
  PackageParser.parse_cran_packages
  puts "Job Completed at #{Time.now}"
end

scheduler.join
