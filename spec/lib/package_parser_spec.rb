# frozen_string_literal: true

require 'spec_helper'

require_relative '../../app/lib/package_parser'

RSpec.describe PackageParser do
  let(:expected_packages) do
    { A3: { md5sum: '027ebdd8affce8f0effaecfcd5f5ade2', package: 'A3', version: '1.0.0' },
      AalenJohansen: { md5sum: 'd7eb2a6275daa6af43bf8a980398b312', package: 'AalenJohansen', version: '1.0' } }
  end

  let(:expected_package_info) do
    {
      "Date/Publication": '2015-08-16 23:05:52',
      "Package Name": 'A3',
      "R Version needed": '2.15.0',
      Authors: 'Scott Fortmann-Roe',
      Dependencies: 'R (>= 2.15.0),xtable,pbapply',
      License: 'GPL (>= 2)',
      Maintainers: 'Scott Fortmann-Roe <scottfr@berkeley.edu>',
      Title: 'Accurate, Adaptable, and Accessible Error Metrics for Predictive',
      Versions: '1.0.0'
    }
  end

  describe '.parse_cran_packages' do
    before do
      FileUtils.mkdir_p('tmp/packages_details/')

      stub_request(:get, 'https://cran.r-project.org/src/contrib/PACKAGES.gz')
        .to_return(body: File.read('spec/fixtures/PACKAGES.gz'))

      stub_request(:get, 'https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz')
        .to_return(body: File.read('spec/fixtures/A3_1.0.0.tar.gz'))

      stub_request(:get, 'https://cran.r-project.org/src/contrib/AalenJohansen_1.0.tar.gz')
        .to_return(body: File.read('spec/fixtures/AalenJohansen_1.0.tar.gz'))

      stub_const('PACKAGES_DIR', 'tmp')
    end
    context 'when downlading the package first time' do
      before do
        File.write('tmp/packages.json', JSON.generate({}))
      end

      it 'parses the packages correctly and downloads the files' do
        PackageParser.parse_cran_packages

        packages = JSON.parse(File.read('tmp/packages.json'), symbolize_names: true)
        package_info = JSON.parse(File.read('tmp/packages_details/A3_1.0.0.json'), symbolize_names: true)

        expect(packages).to eq(expected_packages)
        expect(package_info).to eq(expected_package_info)
      end
    end

    context 'when some packages were alraedy downloaded' do
      before do
        already_parsed = { "A3": { "package": 'A3', "version": '1.0.0', "md5sum": '027ebdd8affce8f0effaecfcd5f5ade2' } }
        File.write('tmp/packages.json', JSON.generate(already_parsed))
      end

      it 'does not download the file if its not updated' do
        PackageParser.parse_cran_packages

        expect(a_request(:get, 'https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz')).to_not have_been_made
      end
    end
  end
end
