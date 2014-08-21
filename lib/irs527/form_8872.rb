module Irs527
  class Form8872 < Form
    attr_accessor :line
    attr_reader :sched_b_forms, :sched_a_forms

    HEADERS = [:record_type, :form_type, :form_id, :period_beg_date, :period_end_date,
      :init_rpt, :amend_rpt, :final_rpt, :change_of_addr, :name, :ein]

    FOOTERS = [:qtr_indicator, :monthly_rpt, :pre_elect, :elect_date, :elect_state, :sched_a,
      :sched_b, :total_sched_a, :total_sched_b, :date
    ]

    def initialize(line, properties)
      @line       = line
      @properties = properties
      @sched_a_forms = []
      @sched_b_forms = []
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

    def truncated?
      @line.length < 49
    end

    def truncated=(missing_fields)
      @line.concat(missing_fields)
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

    def a_record=(supp_line)
      @sched_a_forms << {
        record_type: supp_line[0],
        form_id: supp_line[1],
        sched_a_id: supp_line[2],
        org_name: supp_line[3],
        ein: supp_line[4],
        contrib_name: supp_line[5],
        addr: addr("A", supp_line[6..11]),
        employer: supp_line[12],
        contrib_amt: supp_line[13].to_f,
        contrib_occupation: supp_line[14],
        agg_contrib_ytd: supp_line[15],
        date: format(:date, supp_line[16])
      }
    end

    def b_record=(supp_line)
      @sched_b_forms << {
        record_type: supp_line[0],
        form_id: supp_line[1],
        sched_b_id: supp_line[2],
        org_name: supp_line[3],
        ein: supp_line[4],
        recip_name: supp_line[5],
        addr: addr("B", supp_line[6..11]),
        employer: supp_line[12],
        expenditure_amt: supp_line[13].to_f,
        recip_occupation: supp_line[14],
        date: format(:date, supp_line[15]),
        expenditure_purpose: supp_line[16]
      }
    end

    def incomplete?
      !@line.nil?
    end
  end
end