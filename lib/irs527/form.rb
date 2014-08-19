module Irs527
  class Form
    EXEMPTIONS = [:exempt_8872, :exempt_990, :related_entity_bypass, :eain_bypass, :init_rpt, :amend_rpt, :final_rpt]
    def initialize(line)
      @line = line.chomp.split("|")
    end

    def parse_line
      form =  case @line[0]
              when '1'
                Form8871.new(@line, form_properties[:form_8871])
              end
      if form
        form.parse_properties
        return form
      end
    end

    def form_properties
      {
        form_8871: {
          header: 0..6,
          org: {
            name: 7,
            addr: (8..13),
            email: 14,
            estab_date: 15
          },

          custodian: {
            name: 16,
            addr: (17..22)
          },

          contact: {
            name: 23,
            addr: (24..29)
          },

          business: {
            addr: (30..35)
          },

          footer: 36..-1
        },

        form_8872: {}
      }
    end

    def format!(property, val)
      return nil if val.nil? || val.empty?
      val = if exemption?(property)
              val == "1"
            elsif date_check?(property)
              val.length <= 8 ? Date.strptime(val, "%Y%m%d") : Date.strptime(val, "%Y-%m-%d %H:%M:%S")
            else
              val
            end

      return val
    end

    def exemption?(property)
      EXEMPTIONS.include?(property)
    end

    def date_check?(property)
      [:estab_date, :date].include?(property)
    end

    def addr(category, section)
      keys = ["addr_one", "addr_two", "city", "state", "zip", "zip_ext", "other"]
      keys.map! { |key| "#{category}_#{key}".to_sym }
      hash = {}

      keys.each do |key|
        hash[key] = section.shift
      end

      return hash
    end
  end
end