require 'spec_helper'

describe "stocks/new" do
  before(:each) do
    assign(:stock, stub_model(Stock,
      :code => "MyString",
      :name => "MyString",
      :price => 1.5
    ).as_new_record)
  end

  it "renders new stock form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stocks_path, "post" do
      assert_select "input#stock_code[name=?]", "stock[code]"
      assert_select "input#stock_name[name=?]", "stock[name]"
      assert_select "input#stock_price[name=?]", "stock[price]"
    end
  end
end
