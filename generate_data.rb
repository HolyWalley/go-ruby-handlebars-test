require 'csv'

# Configuration
file_name = "large_file.csv"
number_of_rows = 10_000
headers = ["name", "role"]

CSV.open(file_name, "wb") do |csv|
  csv << headers

  number_of_rows.times do |i|
    name = "Name #{i}"
    role = "user #{i}"

    csv << [name, role]
  end
end

puts "CSV file '#{file_name}' with #{number_of_rows} rows has been generated."
