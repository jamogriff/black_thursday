require 'BigDecimal/util'

class Compute

  def self.mean(sum, num_of_elements)
    if sum.class == BigDecimal
      mean = sum / num_of_elements
    else
      mean = sum.to_f / num_of_elements
    end
    mean.round(2)
  end

  def self.standard_deviation(numbers)
    if numbers.class == Hash
      hash_of_numbers = numbers.values
      mean = self.mean(hash_of_numbers.sum, hash_of_numbers.length)
      adder_counter = hash_of_numbers.sum do |number|
        (number - mean)**2
      end
      Math.sqrt(adder_counter.to_f / (hash_of_numbers.length - 1)).round(2)
    else
      array_of_numbers = numbers
      mean = self.mean(array_of_numbers.sum, array_of_numbers.length)
      adder_counter = array_of_numbers.sum do |number|
        (number - mean)**2
      end
      Math.sqrt(adder_counter.to_f / (array_of_numbers.length - 1)).round(2)
    end
  end
end
