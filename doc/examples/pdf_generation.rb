#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

url = 'https://en.wikipedia.org/wiki/Consistency_model'
pdf = Hausgold::Pdf.new(url: url)
pdf.landscape = false

pdf.portrait?
# => false

pdf.format = 'A5'
pdf.format.A5?
# => true

pdf.margin = '2cm'

# Kick on the PDF generation
pdf.save!

# Poll for the download URL (can take multipe cycles due to generation)
while pdf.url == url
  begin
    pdf.reload
  rescue Hausgold::EntityNotFound
    sleep 1
  end
end

dest = File.join(__dir__, 'wiki.pdf')
pdf.download(dest)

pp File.new(dest).size
