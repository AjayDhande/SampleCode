#!/usr/bin/env ruby
require 'byebug'

puts "Enter ISBN13 barcode....."
num=gets.chomp
total=0
num_array=num.to_s.split('').map(&:to_i)
for i in num_array do  
  total = i*[1,3].sample + total
end
mod_value = total % 10
result = 10 - mod_value
if result==10
  result = 0;
end
total_result = num+"#{result}"
puts "ISBN is:"+total_result
