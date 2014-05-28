require 'typhoeus'
require 'nokogiri'

class Scraper

  URL_BASE = 'doctor.webmd.com'
  URL_PATH = 'results'
=begin
  NUM_RESULTS = 716314
  PAGE_SIZE = 1000
  PARAMS = {
    zip: 50001,
    distance: 5000,
    so: 'name',
    pagesize: PAGE_SIZE
  }
=end
  NUM_RESULTS = 39378
  PAGE_SIZE = 1000
  PARAMS = {
    zip: 50001,
    distance: 250,
    so: 'name',
    pagesize: PAGE_SIZE
  }
  MAX_PAGE = NUM_RESULTS / PAGE_SIZE + 1
  MAX_REQUESTS = 50

  def initialize
  end

  def run
    hydra = Typhoeus::Hydra.new(max_concurrency: MAX_REQUESTS)
    (1..MAX_PAGE).each do |i|
      request = make_request i
      request.on_complete do |response|
        handle_response response
      end
      puts "Enqueuing request for page #{i}/#{MAX_PAGE}"
      hydra.queue(request)
    end
    hydra.run
  end

  private

  def make_request(page)
    params = PARAMS.clone
    params[:pagenumber] = page
    Typhoeus::Request.new(
      "#{URL_BASE}/#{URL_PATH}",
      method: :get,
      params: params
    )
  end

  def handle_response(response)
    page = Nokogiri::HTML(response.body)
    page.css('li.result').each do |result|
      parse result
    end
  end

  def parse(result)
    doctor = {}
    doctor[:name] = result.css('h2').text
    doctor[:specialty] = result.css('h3.specialty').text
    doctor[:address] = result.css('p.address').text
    begin
      Doctor.create(doctor)
    rescue Exception => e # Probably want to be more specific than this
      puts "Doctor with name #{doctor[:name]}, specialty " +
           "#{doctor[:specialty]}, address #{doctor[:address]} " +
           "already found in database."
    end
  end
end
