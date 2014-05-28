require './lib/scraper'

task :scrape do
  Scraper.new.run
end
