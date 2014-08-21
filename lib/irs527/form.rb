module Irs527
  class Form
    EXEMPTIONS = [:exempt_8872, :exempt_990, :related_entity_bypass,
      :eain_bypass, :init_rpt, :amend_rpt, :final_rpt, :change_of_addr,
      :sched_a, :sched_b
    ]
    def initialize(line)
      @line = line.chomp.split("|")
    end

    def supplementary?
      ["D", "R", "E"].include?(@line[0])
    end

    def parse_line
      form =  case @line[0]
              when '1'
                Form8871.new(@line, form_properties[:form_8871])
              when '2'
                Form8872.new(@line, form_properties[:form_8872])
              when 'B'
                FormSchedB.new(@line, form_properties[:sched_b])
              when 'A'
                FormSchedA.new(@line, form_properties[:sched_a])
              end

      if form
        form.parse_properties
        return form
      end
    end

    def form_properties(form={})
      form[:form_8871] = {
        header: 0..7,
        org: {addr: 8..13, email: 14, estab_date: 15},
        custodian: {name: 16, addr: 17..22},
        contact: {name: 23, addr: 24..29},
        business: {addr: 30..35},
        footer: 36..-1
      }

      form[:form_8872] = {
        header: 0..11,
        org: {addr: 12..17, email: 18, estab_date: 19},
        custodian: {name: 20, addr: 21..26},
        contact: {name: 27, addr: 28..33},
        business: {addr: 34..39},
        footer: 40..-1
      }

      form[:sched_a] = {
        header: 0..5,
        contributor: {addr: 6..11, employer: 12},
        footer: 13..-1
      }

      # they appear identical
      form[:sched_b] = form[:sched_a]

      return form
    end

    def format(property, val)
      return nil if val.nil? || val.empty?
      val = if exemption?(property)
              val == "1"
            elsif date_check?(property)
              val.length <= 8 ? Date.strptime(val, "%Y%m%d") : Date.strptime(val, "%Y-%m-%d %H:%M:%S")
            else
              val
            end

      if block_given?
        yield val
      else
        return val
      end
    end

    def exemption?(property)
      EXEMPTIONS.include?(property)
    end

    def date_check?(property)
      [:estab_date, :date].include?(property)
    end

    def addr(type, section)
      keys = ["addr_one", "addr_two", "city", "state", "zip", "zip_ext", "other"]
      keys.map! { |key| "#{type}_#{key}".to_sym }
      hash = {}

      keys.each do |key|
        hash[key] = section.shift
      end

      return hash
    end

    def update(form)
      record_type = "#{@line[0].downcase}_record=".to_sym
      form.send(record_type, @line)
    end
  end
end