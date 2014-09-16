require "minitest/autorun"
require "irs527"
require "date"
require "csv"
require "pry"
class TestFormList < MiniTest::Test
  def setup
    @form_list = Irs527::Utility.generate_index("test/sample.txt", "test/sample.csv")
    @csv = CSV.read("test/sample.csv", "r")
    @query = @form_list.query("371401847")
  end

  def test_name_of_org_matches_index
    assert @form_list["454919869"][:name] == @csv[0][1]
  end

  def test_form_list_loads_correctly
    assert_instance_of Irs527::FormList, Irs527::FormList.load("test/sample.csv", "test/sample.txt")
  end

  def test_proc_objects_return_form_8871_objects_when_called
    forms = @form_list["454919869"][:forms][:form_8871].map { |form| form.call }
    assert forms.all? { |form| form.is_a?(Irs527::Form8871) }
  end

  def test_proc_objects_return_form_8872_objects_when_called
    forms = @form_list["371401847"][:forms][:form_8872].map { |form| form.call }
    assert forms.all? { |form| form.is_a?(Irs527::Form8872) }
  end

  def test_query_object_gets_created
    assert_instance_of Irs527::Query, @query
  end

  def test_names_returns_hash_of_orgs_and_eins
    assert @form_list.names[0] == { ein: "454919869", name: "BOB SQUERI FOR DISTRICT 7 SUPERVISOR 2012" }
    assert @form_list.names[1] == { ein: "593417598", name: "Florida Chamber of Commerce CCE" }
  end
end