module Irs527
  class Form8872
    HEADERS = [:record_type, :form_type, :form_id, :period_beg_date, :period_end_date,
      :amend_rpt, :final_rpt, :init_rpt, :change_of_addr, :name, :ein]

    FOOTERS = [:qtr_indicator, :monthly_rpt, :pre_elect, :elect_date, :elect_state, :sched_a,
      :sched_b, :total_sched_a, :total_sched_b, :date
    ]

    def initialize(line, properties)
      @line       = line
      @properties = properties
    end

    def quarter_indicator(value)
      case value.downcase
      when "a"
        "First Quarterly"
      when "b"
        "Second Quarterly"
      when "c"
        "Third Quarterly"
      when "d"
        "Year-End"
      when "e"
        "First Year"
      when "f"
        "Monthly"
      when "g"
        "Pre-Election"
      when "h"
        "Post-Election"
      else
        nil
      end
    end

    def month(val)
      Date::ABBR_MONTHNAMES[val.to_i]
    end

    def footer(foot)
      FOOTERS.each_with_index do |f,i|
        value = case f
                when :total_sched_a
                  foot[i].to_f
                when :total_sched_b
                  foot[i].to_f
                when :qtr_indicator
                  quarter_indicator(foot[i])
                when :monthly_rpt
                  monthly(foot[i])
                else
                  format(f, foot[i])
                end

        instance_variable_set("@#{f}", value)
      end
    end

    def header(head)
      HEADERS.each_with_index do |h,i|
        val = format(h, head[i])
        define_var(h, val)
      end
    end
  end
end