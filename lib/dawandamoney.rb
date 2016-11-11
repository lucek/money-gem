require "dawandamoney/version"

module Dawandamoney
  @convertion_rates = {}

  def self.convertion_rates(currency_code, convertion_rates)
    raise ConversionRatesIsNotAHashError unless convertion_rates.is_a?(Hash)
    raise ConversionRatesAreNotNumbersError unless convertion_rates.map { |k,v| v }.all? { |i| i.is_a?(Numeric) }

    @convertion_rates[currency_code.to_sym] = convertion_rates
  end
end

class ConversionRatesIsNotAHashError < StandardError
end

class ConversionRatesAreNotNumbersError < StandardError
end
