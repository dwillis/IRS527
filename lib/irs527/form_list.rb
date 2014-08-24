module Irs527
  class FormList
    attr_accessor :incomplete

    def initialize
      @forms = {}
    end

    def search_by_name(name)
      names.find { |org| org[0] == name }
    end

    def names
      @forms.keys.map { |form| [@forms[name].name, form] }
    end

    def most_recent_filing(ein)
      filings = @forms[ein]
      filings.sort_by { |filing| filing.date }
    end

    def size
      @forms.keys.map { |form| form.length }
    end

    def show_non_amended_reports(ein)
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
        @forms[ein].inject { |x,y| x.is_a?(Form8872) ? x.contribution_total + y.contribution_total : 0.0 }
      else
        @forms.keys.map { |ein| sum_contributions(ein) }.inject { |x, y| x + y }
      end
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
      @forms[ein]
    end

    def add(ein, form)
      if @forms[ein]
        @forms[ein] << form.create!
      else
        @forms[ein] = [form.create!]
      end
    end

    def fix_incomplete(line)
      p line
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
  end
end