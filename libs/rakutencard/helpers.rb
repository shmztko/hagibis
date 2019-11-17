require 'date'
require 'time_difference'

module RakutenCard
  class Validator
    def initialize(target_year, target_month)
        @given = Time.local(target_year, target_month)
        @current = Time.local(Time.now.year, Time.now.month)
    end

    def is_future?
        @given > @current
    end

    def retention_period_exceeded?
        # 楽天カードの明細は、13ヶ月前までしか閲覧できない。
        TimeDifference.between(@given, @current).in_months > 13
    end
  end

  class TabResolver
    def self.get_tab_index(target_year, target_month)
        first_day_of_current_month = Time.local(Time.now.year, Time.now.month)
        first_day_of_target_month = Time.local(target_year, target_month)
        if first_day_of_current_month - first_day_of_target_month < 0
            raise "Can't get tab index for future date. year : #{target_year}, month : #{target_month}"
        end
        # NOTES : Need to +1 after calculate difference of two dates.
        #         According to following specification.
        # ====================================================
        # Specification of tab number for Rakuten E-navi page
        # payment detail for next month : tab number = 0
        # payment detail for current month : tab number = 1
        # payment detail for previous month : tab number = 2
        # ====================================================
        # Example.
        # Today : 2019-10-13
        # Tab Number = 0 : Payment detail for 2019-11
        # Tab Number = 1 : Payment detail for 2019-10
        # Tab Number = 2 : Payment detail for 2019-09
        TimeDifference.between(first_day_of_current_month, first_day_of_target_month).in_months.round + 1
    end
  end
end