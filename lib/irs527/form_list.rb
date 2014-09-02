module Irs527
  class FormList
    attr_accessor :incomplete


    def self.load(csv_file, file)
      form_paths = {}

      CSV.foreach(csv_file) do |row|
        ein = row.shift

        form_paths[ein] = ->() {
          row.each_slice(2).map do |form|
            Utility.parse_form(IO.read(file, form[0].to_i, form[1].to_i))
          end
        }
      end

      new(form_paths, file)
    end

    def initialize(forms, file)
      @forms = forms
      @file = file
    end

    def most_recent_non_amend(ein)
      non_amended(ein).max { |form| form.date }
    end

    def non_amended(ein)
      @forms[ein].select { |form| form.non_amend? }
    end

    def all_non_amended
      # Expensive method. Do not use this.
      non_amended = []
      @forms.each do |ein,form_list|
        @forms[ein] = form_list.call if form_list.is_a?(Proc)
        non_amended << form_list.select { |form| form.non_amend? }
      end

      non_amended
    end

    def eins
      @forms.keys
    end

    def sum_contributions(ein)
      non_amended(ein).inject { |x,y| x.contrib_total + y.contrib_total }
    end

    def [](ein)
      if @forms[ein]
        if @forms[ein].is_a?(Proc)
          @forms[ein] = @forms[ein].call
        else
          @forms[ein]
        end
      else
        puts "#{ein} not found."
      end
    end
  end
end