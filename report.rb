require 'date'
require 'time'
require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow
require './classes/timesheet'
require './classes/employee'
require './classes/errors'
require './module/payable_leave'

# Include methods to generate json and csv files for managers access
class Report
    @@employee_file = JSON.load_file('employees.json', symbolize_names: true)
    @@headers = ["Name", "ID", "Clock-In", "Clock-Out", "Working Hours", "Leave Applied", "Leave Minutes"]

    def self.employee_file
        return @@employee_file
    end

    def self.headers
        return @@headers
    end

    def self.generate_json
        employee_file.each { |employee| employee.delete(:password) }
        File.write('timesheets.json', JSON.pretty_generate(timesheet_file))
    end

    def self.generate_csv
        CSV.open('report.csv', 'a', headers: headers, write_headers: true) do |csv|
            Timesheet.timesheet_file.each do |hash|
                hash[:timesheets].each do |hash2|
                    csv << hash2.values
                end
            end
        end
    end
end
