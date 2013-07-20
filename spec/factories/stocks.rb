# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock do
    code "MyString"
    name "MyString"
    price 1.5
    lastdate "2013-07-20"
  end
end
