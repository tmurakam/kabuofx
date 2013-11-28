# -*- coding: utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stock do
    code "1111"
    name "テスト"
    price 1234
    lastdate "2013-07-20"
  end
end
