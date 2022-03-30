require 'date'
require 'time'
require 'json'
require 'csv'
require 'tty-prompt'
require 'rainbow/refinement'
using Rainbow

require './classes/employee'
require './classes/errors'

# Create instances of timesheet everytime user creates a new timesheet entry
class Timesheet
    attr_accessor :timesheet

    @@timesheet_file = JSON.load_file('timesheets.json', symbolize_names: true)
    @@prompt = TTY::Prompt.new(interrupt: :exit)

    def initialize(start, finish, leave, time)
        @timesheet = {
          start_time: start,
          finish_time: finish,
          working_hours: (finish - start) / 3600,
          leave_type: leave,
          leave_time: time
        }
    end

    def self.timesheet_file
        return @@timesheet_file
    end

    def self.date(period)
        begin
            input = @@prompt.ask("Enter #{period.underline} (DD.MM.YYY):", required: true)
            date = Date.parse(input)
            raise(InvalidDateError) if date.cweek != Date.today.cweek
        rescue ArgumentError
            raise(InvalidDateError)
        end
        return date
    end

    def self.time_casting(period)
        input = @@prompt.ask("Enter #{period.underline} (HH:MM - 24H):", required: true).split(/:/)
        # "08" and "09" cannot be casted to Integer so need to delete prefix "0"
        new_input = input.map { |number| number.delete_prefix("0") }
        raise(InvalidTimeError) if new_input.include?('.')

        return new_input
    end

    def self.time(date, period)
        begin
            input = time_casting(period)
            time = Time.new(date.year, date.month, date.day, Integer(input[0]), Integer(input[1]), 0)
        rescue ArgumentError
            raise(InvalidTimeError)
        end
        return time
    end

    def self.display_timesheet(name, start, finish, leave)
        puts "#{name.capitalize}'s New Timesheet".underline.bg(:antiquewhite).black.bright
        puts "-" * 40
        puts "Start: #{start.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Finish: #{finish.strftime('%d.%m.%Y -> %H:%M').bright.green}"
        puts "Leave applied: #{leave[0].bright.green} leave -> #{leave[1].to_s.bright.green} minutes"
        puts "-" * 40
    end
end