module Irs527
  class Query
    attr_reader :org_name
    def initialize(form_set, ein=nil)
      @org_name  = form_set[:name]
      @ein       = ein
      @form_8871 = form_set[:forms][:form_8871].map { |form| form.call }
      @form_8872 = form_set[:forms][:form_8872].map { |form| form.call }
    end

    def non_amended
      @form_8872.select { |form| form.non_amend? }
    end

    def forms
      @form_8872 + @form_8871
    end

    def most_recent_non_amend
      non_amended.max { |form| form.date }
    end

    def contributors
      @form_8872.map { |form| form.sched_a_forms }.flatten
    end

    def expenditures
      @form_8872.map { |form| form.sched_b_forms }.flatten
    end

    def sum_contributions
      contributors.map { |form| form[:contrib_amt] }.inject(:+) || 0.0
    end

    def sum_expenditures
      expenditures.map { |form| form[:expenditure_amt] }.inject(:+) || 0.0
    end

    def mission_statement
      @form_8871.size > 0 ? @form_8871.first.purpose : "None Listed"
    end

    def most_recent_form
      form = forms.min { |form| form.date }
      form.date if form
    end

    def to_s
      puts "Name: #{@org_name}, EIN: #{@ein}"
      puts "Purpose: #{mission_statement}"
      puts "8871 forms: #{@form_8871.length}"
      puts "8872 forms: #{@form_8872.length}"
      puts "Contributions: #{sum_contributions}"
      puts "Expenditures: #{sum_expenditures}"
      puts "Founding Date: #{@form_8871.last.date}" if @form_8871.size > 0
      puts "Last Updated: #{most_recent_form}\n\n"
    end
  end
end