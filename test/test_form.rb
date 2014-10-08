require "minitest/autorun"
require "irs527"
require "date"

class TestForm < MiniTest::Test
  def setup
    @file = File.readlines("test/sample.txt").map { |line| line.split("|") }
    @form_8872 = Irs527::Form.new(@file[27])
    @supp_8872 = Irs527::Form.new(@file[28])
    @form_8871 = Irs527::Form.new(@file[0])
    @supp_8871 = Irs527::Form.new(@file[1])
  end

  def test_line_is_valid
    assert Irs527::Form.valid?(@file[0])
  end

  def test_form_type_is_correct
    assert_equal @form_8872.type[:form_type] == :form_8872, true
    assert_equal @form_8871.type[:form_type] == :form_8871, true
    assert_equal @supp_8871.type[:form_type] == :d_record, true
    assert_equal @supp_8872.type[:form_type] == :sched_a, true
  end

  def test_form_creation_for_primary_forms
    assert_instance_of Irs527::Form8871, @form_8871.create!
    assert_instance_of Irs527::Form8872, @form_8872.create!
  end

  def test_supplementary_forms
    assert_equal @supp_8871.supplementary?, true
    assert_equal @supp_8872.supplementary?, true
    assert_equal @form_8872.supplementary?, false
  end

  def test_supplementary_form_can_update
    form_8871, form_8872 = @form_8871.create!, @form_8872.create!
    assert form_8871.respond_to? :d_record=
    assert form_8872.respond_to? :sched_a=
  end

  def test_supplementary_form_updates_primary
    form_8871, form_8872 = @form_8871.create!, @form_8872.create!
    d_records = form_8871.send("#{@supp_8871.type[:form_type]}=", @supp_8871.line)
    sched_as = form_8872.send("#{@supp_8872.type[:form_type]}=", @supp_8872.line)
    assert form_8871.d_records.length == 1
    assert form_8872.sched_a_forms.length == 1
  end
end
