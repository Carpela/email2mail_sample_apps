#!/usr/bin/env ruby 
require 'rubygems'
require 'postalmethods'
api_key = '1518ebdf-3464-47b1-8333-ff49ac1ee73f'

options = {
  :api_key => api_key
}

address = {
  :AttentionLine1 => "The White House",
  :Address1 => "1600 Pennsylvania Avenue NW",
  :City => "Washington",
  :State => "DC",
  :PostalCode => "20500",
  :Country => "USA"
}

client = PostalMethods::Client.new(options)
client.prepare!

document = open 'sample_letter.html'
retvalue = client.send_letter_with_address(
  document,
  "This is a sample description",
  address)

p "Return value:"
p retvalue
delivery_status, last_update = client.get_letter_status(retvalue)
p "Delivery status:"
p delivery_status, last_update

statuses = client.get_letter_details(retvalue)
p "Leter details:"
p statuses
retvalue = 1338109
pdf_file = client.get_pdf(retvalue)
p "Letter PDF:"
p pdf_file.class

open('result.pdf', 'wt').write pdf_file
