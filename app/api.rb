# frozen_string_literal: true

# this is the api used to get the packages information and cached details of every package
require 'sinatra'
require 'json'

get '/packages' do
  content_type :json
  file_content = File.read("#{PACKAGES_DIR}/packages.json")
  packages_info = JSON.parse(file_content)

  JSON.generate(packages_info)
end

get '/packages/:name/:version' do
  content_type :json
  package_name = params['name']
  package_version = params['version']
  package_file_path = "#{PACKAGES_DIR}/packages_details/#{package_name}_#{package_version}.json"

  if File.file?(package_file_path)
    package_details = JSON.parse(File.read(package_file_path))
    JSON.generate(package_details)
  else
    status 404
  end
end
