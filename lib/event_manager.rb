require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'
require 'pry'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_numbers(phone)
  if phone.length == 10 || (phone.length == 11 && phone[0] == "1")
    phone[-10..-1]
  else
    ""
  end
end

def clean_date(date)
  hour = date.split[1].split(":")[0]
  month = date.split("/")[0]
  day = date.split("/")[1]
  year = "20#{date.split("/")[2].split[0]}"
  day_of_week = DateTime.new(year.to_i, month.to_i, day.to_i).strftime("%A")
  return hour, day_of_week
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcodes(row[:zipcode])

  phone = clean_phone_numbers(row[:homephone].delete(".-").gsub(/[()]/, "").gsub(/ /, ""))

  hour, day_of_week = clean_date(row[:regdate])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)

  puts "#{phone} #{hour} #{day_of_week}"

end
