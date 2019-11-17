require "thor"
require_relative "./command"
module RCardBilling
  class CLI < Thor
  
    desc "save YEAR MONTH", "Save billing statement of given year/month."
    def save(year, month)
      command = RCardBilling::Command.new
      command.save(year, month)
    end

    desc "save_between FROM_YEAR FROM_MONTH TO_YEAR TO_MONTH", "Save billing statement between given year/month."
    def save_between(from_year, from_month, to_year, to_month)
      from = Time.local(from_year, from_month)
      to = Time.local(to_year, to_month)
  
      command = RCardBilling::Command.new
      command.save_between(from, to)
    end
  
    desc "save_from FROM_YEAR FROM_MONTH", "Save billing statement from given year/month to current year/month."
    def save_from(from_year, from_month)
      from = Time.local(from_year, from_month)
      to = Time.local(Time.now.year, Time.now.month)
  
      command = RCardBilling::Command.new
      command.save_between(from, to)
    end
  
    def self.banner(task, namespace = false, subcommand = true)
      super
    end
  end  
end
