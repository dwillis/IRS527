module Irs527
  class FormList
    attr_accessor :incomplete

    # form_list.query(ein, opts={})
    # form_list.query(ein, non_amend: true, most_recent: true)
    def self.load(csv_file, file, type=nil)
      form_paths = {}

      records = CSV.readlines(csv_file)
      records = type.nil? ? records : records.select { |r| r.include?(type) }

      records.each do |row|
        ein = row.shift
        name = row.shift

        form_paths[ein] = {
          name: name,
          forms: {
            form_8871: [],
            form_8872: []
          }
        }

        row.each_slice(3) do |chunk|
          form_paths[ein][:forms][chunk[0].to_sym] << ->() {
            Utility.parse_form(IO.read(file, chunk[1].to_i, chunk[2].to_i))
          }
        end
      end
      new(form_paths, file)
    end

    def initialize(forms, file)
      @forms = forms
      @file = file
      @query = Query.new
    end

    def search_by_name(name)
      result = []
      @forms.keys.each do |ein|
        result << ein if @forms[ein][:name] =~ Regexp.new(name)
      end

      return result.map { |ein| @forms[ein][:forms].call }.flatten
    end

    def [](ein)
      @forms[ein]
    end

    def search_by_ein(ein)
      @forms[ein][:forms].call if @forms[ein]
    end

    def most_recent_non_amend(ein)
      non_amended(ein).max { |form| form.date } if @forms[ein]
    end

    def non_amended(ein)
      @forms[ein][:forms].call.select { |form| form.non_amend? } if @forms[ein]
    end

    def eins
      @forms.keys.map { |ein| { name: @forms[ein][:name], ein: ein } }
    end

    def sum_contributions(ein)
      if @forms[ein]
        form_set = @forms[ein][:forms].call
        form_set.select { |form| form.non_amend? }.inject { |x,y| x.total_sched_a + y.total_sched_b }
      else
        0.0
      end
    end
  end
end