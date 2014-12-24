#!/usr/bin/env ruby
require 'pp'
require 'yaml'
require 'net/http'
require 'nokogiri'

#############
# Variables #
#############

# Tax
taxpercent = 5

# The in file we're going to ingest
infile = ARGV[0]

# Work Directory
workdir = File.dirname(__FILE__)

# Our YAML file containing our item ids for the api
itemfile = "#{workdir}/items.yml"
items    = YAML::load_file(itemfile)

# Our empty Array
data  = Hash.new(0)

# Url we're using our API
url = 'http://api.eve-central.com/api/marketstat'

#############
# Functions #
#############
def lookup(item,items)
  begin

    if items.has_key?(item)
      return items[item]
    end
 
    false

  rescue => msg
    puts "Error in lookup => #{msg}"
    exit
  end
end
  

def comma(number)
  a = number.to_s.split('')
  b = a.size/3.0
  if a.size < 4
    return number.to_s 
  elsif a.size%3 == 0
    n = -4
    (b.to_i-1).times do |i|
      a.insert(n, ',')
      n -= 4
    end
    return a.join("")
  else
      n = -4
    b.to_i.times do |i|
      a.insert(n, ',')
      n -= 4
    end
  return a.join("")
  end
end

########
# Main #
########

begin

  # Exit it the user did not specify any file
  exit if infile == "" or infile == nil

  # Load the file into an array
  if File.exists?(infile) == true
    array = %x[cat #{infile}].split("\n")
  else
    exit 1
  end

  # Loop through the array
  array.each do |e|
    # Let's create a subarray based on tab delimited line
    a = e.split("\t")
 
    # Let's skip the line if nothing exists
    next if a[0].strip == "" or a[0].strip == nil
    next if a[0] == "Time"

    # Now let's define some fields
    # Timestamp
    ts = a[0]

    # User
    user = a[1]
  
    # Item type
    item = a[2]

    # Quantity
    quantity = a[3]
 
    # Item group
    group = a[4]
  
    # Our median (blank for now)
    median = ""
    
    # Look up the item ID from our YAML file
    id = lookup(item,items)

    # Let's skip it if it's not ore
    next if id == false

    # Let's look up the price for our ID
    lookupurl = "#{url}?typeid=#{id}"

    # Let's lookup the xml
    xml = Net::HTTP.get_response(URI.parse(lookupurl)).body

    # Let's parse the xml
    doc = Nokogiri::XML(xml)

    # Let's search through our parsing to find the sell median
    doc.search("sell").each do |e|
      median = e.at('median').text
    end
    
    # Find the value we're paying out
    value = median.to_i * quantity.to_i

    data[user] += median.to_i * quantity.to_i

  end

  printf "%-20s %-20s %s\n", "Payee", "Pay Amount", "Tax"
  data.each do |k,v|
    tax   = v * taxpercent / 100.0
    topay = v - tax
    printf "%-20s %-20s %s\n", "#{k}", "#{comma(topay.to_i)}", "#{comma(tax.to_i)}"
  end

rescue => msg
  puts "Error in Main => #{msg}"
  exit 1
end
