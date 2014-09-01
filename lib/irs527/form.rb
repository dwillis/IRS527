module Irs527

  class Form
    def self.valid?(line)
      line[0] && ['B', 'E', 'A', 'R', 'D', '1', '2'].include?(line[0])
    end

    EXEMPTIONS = [:exempt_8872, :exempt_990, :related_entity_bypass,
      :eain_bypass, :init_rpt, :amend_rpt, :final_rpt, :change_of_addr,
      :sched_a, :sched_b
    ]

    attr_accessor :line

    def initialize(line, supplementary=nil)
      @line = line
      @supplementary = supplementary
    end

    def create!
      form = if type[:form_type] == :form_8871
        Form8871.new(@line, form_properties[:form_8871], type)
      else
        Form8872.new(@line, form_properties[:form_8872], type)
      end

      form.parse_properties
    end

    def type
      @type ||= case @line[0]
                when "1"
                  {form_type: :form_8871, length: 44, ein: @line[6]}
                when "2"
                  {form_type: :form_8872, length: 49, ein: @line[10]}
                when "B"
                  {form_type: :sched_b, length: 17, ein: @line[4]}
                when "R"
                  {form_type: :r_record, length: 13, ein: @line[4]}
                when "D"
                  {form_type: :d_record, length: 13, ein: @line[4]}
                when "E"
                  {form_type: :e_record, length: 5}
                when "A"
                  {form_type: :sched_a, length: 17, ein: @line[4]}
                else
                  nil
                end
    end

    def incomplete?
      @line.length < type[:length]
    end

    def <<(truncated_data)
      @line[-1] << truncated_data.shift
      @line.concat(truncated_data)
    end

    def supplementary?
      ["B", "E", "A", "R", "D"].include?(@line[0])
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
        header: 0..10,
        org: {addr: 11..16, email: 17, estab_date: 18},
        custodian: {name: 19, addr: 20..25},
        contact: {name: 26, addr: 27..32},
        business: {addr: 33..38},
        footer: 39..-1
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
              val.length == 8 ? Date.strptime(val, "%Y%m%d") : Date.strptime(val, "%Y-%m-%d %H:%M:%S")
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
      [:estab_date, :date, :period_beg_date, :period_end_date].include?(property)
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

    def primary?
      type[:form_type] == :form_8871 || type[:form_type] == :form_8872
    end

    def update(form)
      record_type = type[:form_type]
      form.send("#{record_type}=", @line)
    end
  end
end