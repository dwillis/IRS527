module Irs527
  class Form8871 < Form
    def initialize(line, properties)
      @line = line
      @properties = properties
    end

    def parse_properties
      @properties.each do |k,v|
        if v.is_a?(Hash)
          parse(k, v)
        elsif k == :header
          header(@line[v])
        else
          footer(@line[v])
        end
      end
    end

    def footer(foot)
      footers = [
        :exempt_8872, :exempt_state, :exempt_990,
        :purpose, :material_change_date, :date,
        :related_entity_bypass, :eain_bypass
      ]

      footers.each_with_index do |f,i|
        val = format!(f, foot[i])
        define_var(f, val)
      end
    end

    def parse(category, sub_hash)
      sub_hash.each do |k,v|
        if k == :addr
          address = addr(category, @line[v])
          address.each do |sub_cat, val|
            val = format!(sub_cat, val)
            define_var(sub_cat, val)
          end
        else
          define_var(k, @line[v])
        end
      end
    end

    def define_var(cat, val)
      instance_variable_set("@#{cat}", val)
    end

    def header(head)
      headers = [:record_type, :form_type, :form_id, :init_rpt, :amend_rpt, :final_rpt, :ein]
      headers.each_with_index do |h,i|
        val = format!(h, head[i])
        define_var(h, val)
      end
    end
  end
end