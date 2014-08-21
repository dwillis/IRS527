module Irs527
  class Form8872 < Form
    HEADERS = [:record_type, :form_type, :form_id, :period_beg_date, :period_end_date,
      :init_rpt, :amend_rpt, :final_rpt, :change_of_addr, :name, :ein]

    FOOTERS = [:qtr_indicator, :monthly_rpt, :pre_elect, :elect_date, :elect_state, :sched_a,
      :sched_b, :total_sched_a, :total_sched_b, :date
    ]

    def initialize(line, properties)
      @line       = line
      @properties = properties
    end

    def parse_properties
      @properties.each do |property,value|
        if value.is_a?(Hash)
          parse_address(property, value)
        elsif property == :header
          header(@line[value])
        else
          footer(@line[value])
        end
      end
    end

    def parse_address(category, sub_hash)
      sub_hash.each do |k,v|
        if k == :addr
          address = addr(category, @line[v])
          address.each do |sub_cat, val|
            val = format(sub_cat, val)
            instance_variable_set("@#{sub_cat}", val)
          end
        else
          instance_variable_set("@#{k}", @line[v])
        end
      end
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

    def monthly(val)
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
        format(h, head[i]) { |field| instance_variable_set("@#{h}", field) }
      end
    end
  end
end