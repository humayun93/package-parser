# frozen_string_literal: true

require 'zlib'
require 'open-uri'
require 'json'
require 'rubygems/package'
require_relative '../config/constants'

# This is the main class that will parse the CRAN packages and cache the information
# in a JSON files locally. It is assumed here that the md5sum of the package is unique
# and will change if the package is updated or needs to be updated.
# In case the package has already been parsed and the md5sum has not changed,
# the package is not parsed again to prevent redundant requests and processing.
class PackageParser
  class << self
    def parse_cran_packages
      packages = {}
      package_strings = extract_packages_content.split("\n\n")
      package_strings.each do |pkg_str|
        package = parse_package(pkg_str)

        if should_parse_package?(read_packages_file, package)
          parse_cran_package(package)
          packages[package[:package]] = package.slice(*PACKAGES_FIELDS)
        end
      end

      write_packages_file(packages)
    end

    private

    def read_packages_file
      packages_file = File.read("#{PACKAGES_DIR}/packages.json")
      JSON.parse(packages_file)
    end

    def extract_packages_content
      Zlib::GzipReader.new(URI.parse('https://cran.r-project.org/src/contrib/PACKAGES.gz').open).read
    end

    def parse_package(pkg_str)
      package = {}
      pkg_str.split("\n").each do |line|
        key, value = line.split(': ')
        package[key.downcase.to_sym] = value.strip if key && value
      end
      package
    end

    def should_parse_package?(recorded_data, package)
      (
        (package[:package] && package[:version]) &&
        (recorded_data[package[:package]].nil? || recorded_data[package[:package]]['md5sum'] != package[:md5sum])
      )
    end

    def write_packages_file(packages)
      File.write("#{PACKAGES_DIR}/packages.json", JSON.generate(packages))
    end

    def generate_package_url(package)
      "https://cran.r-project.org/src/contrib/#{package[:package]}_#{package[:version]}.tar.gz"
    end

    def download_package_file(package_url, package)
      URI.parse(package_url).open do |io|
        gz = Zlib::GzipReader.new(io)
        tar = Gem::Package::TarReader.new(gz)
        tar.each do |entry|
          return entry.read if entry.full_name == "#{package[:package]}/DESCRIPTION"
        end
      end
    end

    def parse_package_data(extracted_content)
      package_details = {}
      extracted_content.split("\n").each do |line|
        key, value = line.split(': ')
        package_details[key.downcase.to_sym] = value.strip if key && value
      end

      if package_details[:"authors@r"]
        package_details[:author] = "#{package_details[:author]}, #{package_details[:"authors@r"]}"
      end

      package_details.slice(*REQUIRED_FIELDS).merge(extract_dependencies(package_details))
    end

    def extract_dependencies(package_details)
      values = package_details[:depends].split(',').map(&:strip) if package_details[:depends]
      if values
        r_version = values[0].gsub('R (>= ', '').gsub(')', '')
        dependencies = values.join(',')
      end
      { "Dependencies": dependencies || '', "R Version needed": r_version || '' }
    end

    def write_package_data_to_json(package, final_data)
      file_path = "#{PACKAGES_DIR}/packages_details/#{package[:package]}_#{package[:version]}.json"
      File.write(file_path, JSON.generate(final_data))
    end

    def parse_cran_package(package)
      package_url = generate_package_url(package)
      extracted_content = download_package_file(package_url, package)
      package_data = parse_package_data(extracted_content)
      final_data = package_data.transform_keys { |key| TRANSFORM_OUTPUT[key] || key }
      write_package_data_to_json(package, final_data)
    end
  end
end
