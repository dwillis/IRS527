module Irs527
  class FormList
    attr_accessor :incomplete


    def self.load(csv_file, file)
      form_paths = {}

      CSV.foreach(csv_file) do |row|
        ein = row.shift
        name = row.shift

        form_paths[ein] = {
          name: name,
          forms: ->() {
            row.each_slice(2).map do |form|
              Utility.parse_form(IO.read(file, form[0].to_i, form[1].to_i))
            end
          }
        }
      end

      new(form_paths, file)
    end

    def initialize(forms, file)
      @forms = forms
      @file = file
    end

    def search_by_name(name)
      result = []
      @forms.keys.each do |ein|
        result << ein if @forms[ein][:name] =~ Regexp.new(name)
      end

      return result.map { |ein| @forms[ein][:forms].call }.flatten
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