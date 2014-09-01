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

    def search_by_name(name)
      names.find { |org| org[0] == name } || "None by that name"
    end

    def names
      @forms.keys.map { |form| [@forms[form][0].name, form] }
    end

    def size
      @forms.keys.map { |form| @forms[form].length }
    end

    def most_recent_non_amend(ein)
      non_amended(ein).max { |form| form.date }
    end

    def non_amended(ein)
      @forms[ein].select { |form| form.non_amend? }
    end

    def all_non_amended
      non_amended = []
      @forms.each do |ein,form_list|
        non_amended << form_list.select { |form| form.non_amend? }
      end

      non_amended
    end

    def keys
      @forms.keys
    end

    def sum_contributions(ein=nil)
      if ein
        non_amended(ein).inject { |x,y| x.contrib_total + y.contrib_total }
      else
        @forms.keys.map { |ein| sum_contributions(ein) }.inject { |x,y| x + y }
      end
    end

    def forms_8872
    end

    def []=(ein, form)
      @forms[ein] = [form.create!]
    end

    def supplementary_update(ein, sub_form)
      form_type = sub_form.type[:form_type]
      primary_form = @forms[ein].last
      primary_form.send("#{form_type}=", sub_form.line)
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

    def add(ein, form)
      if @forms[ein]
        @forms[ein] << form.create!
      else
        @forms[ein] = [form.create!]
      end
    end

    def fix_incomplete(line)
      if @incomplete
        @incomplete << line

        unless @incomplete.incomplete?
          ein = @incomplete.type[:ein]
          if @incomplete.supplementary?
            supplementary_update(ein, @incomplete)
          else
            add(ein, @incomplete)
          end
          @incomplete = nil
        end
      end
    end

    def to_csv
      CSV.open("file_map.csv", "w") do |csv|
        @forms.each do |k,v|
          line = @forms[k]
          ein = line.shift
          form_route = line.map { |p| [p[:length], p[:offset]] }.flatten
          csv << ([ein] + form_route)
        end
      end
    end
  end
end