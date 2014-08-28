require "minitest/autorun"
require "irs527"
require "date"
class TestForm7781 < MiniTest::Test
  def setup
    @file = File.open("test/sample.txt")
    @line = @file.readline.split("|")
    @form = Irs527::Form.new(@line)
  end

  def test_line_for_form_validity
    assert Irs527::Form.valid?(@line), true
  end

  def test_line_is_form_8871
    assert_equal @form.type[:form_type], :form_8871
  end

  def test_form_gets_created_as_8871
    form = @form.create!
    assert_instance_of Irs527::Form8871, form
  end

  def test_subsequent_rows_are_supplementary
    line = @file.readline.split("|")
    form = Irs527::Form.new(line)
    assert_equal form.supplementary?, true
  end
end