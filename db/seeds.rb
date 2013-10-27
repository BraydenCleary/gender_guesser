require 'csv'

CSV.foreach('seed_data.csv', headers: true) do |row|
  Person.create!(row.to_hash)
end


