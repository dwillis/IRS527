module Irs527
  class Form8871 < Form
    FOOTERS = [
      :exempt_8872, :exempt_state, :exempt_990,
      :purpose, :material_change_date, :date,
      :related_entity_bypass, :eain_bypass
    ]

    HEADERS = [:record_type, :form_type, :form_id, :init_rpt, :amend_rpt, :final_rpt, :ein]

    def initialize(line, properties)
      @line = line
      @properties = properties
      @d_records = []
      @r_records = []
      @e_records = []
    end

    def parse_properties
      @properties.each do |property,value|
        if value.is_a?(Hash)
          parse(property, value)
        elsif property == :header
          header(@line[value])
        else
          footer(@line[value])
        end
      end
    end

    def parse(category, sub_hash)
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

    def footer(foot)
      FOOTERS.each_with_index do |f,i|
        format(f, foot[i]) { |field| instance_variable_set("@#{f}", field) }
      end
    end

    def header(head)
      HEADERS.each_with_index do |h,i|
        format(h, head[i]) { |field| instance_variable_set("@#{h}", field) }
      end
    end

    def d_record=(supp_line)
      @d_records << {
        form_id: supp_line[1],
        director_id: supp_line[2],
        org_name: supp_line[3],
        ein: supp_line[4],
        addr: addr("D", supp_line[5..10])
      }
    end

    def r_record=(supp_line)
      @r_records << {
        form_id: supp_line[1],
        entity_id: supp_line[2],
        org_name: supp_line[3],
        ein: supp_line[4],
        addr: addr("R", supp_line[5..-1])
      }
    end

    def e_record=(supp_line)
      @e_records << {
        form_id: supp_line[1],
        eain_id: supp_line[2],
        elect_auth_id: supp_line[4],
        state_issued: supp_line[5]
      }
    end
  end
end