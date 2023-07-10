# frozen_string_literal: true

require 'spec_helper'
require_relative '../app/api'

RSpec.describe 'CRAN package API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    stub_const('PACKAGES_DIR', 'spec/fixtures')
  end

  describe 'GET /api/cran_packages' do
    let(:packages) { JSON.parse(File.read('spec/fixtures/PACKAGES.json')) }

    it 'returns a list of all packages' do
      get '/packages'
      expect(last_response.status).to eq 200
      expect(last_response.content_type).to eq 'application/json'
      expect(JSON.parse(last_response.body)).to eq packages
    end
  end

  describe 'GET /packages/:name/:version' do
    let(:package_details) { JSON.parse(File.read('spec/fixtures/packages_details/A3_1.0.0.json')) }

    context 'when the package exists' do
      it 'returns the package information' do
        get '/packages/A3/1.0.0'
        expect(last_response.status).to eq 200
        expect(last_response.content_type).to eq 'application/json'
        expect(JSON.parse(last_response.body)).to eq package_details
      end
    end

    context 'when the package does not exist' do
      it 'returns a 404 error' do
        get '/packages/A3/2.0.0'
        expect(last_response.status).to eq 404
      end
    end
  end
end
