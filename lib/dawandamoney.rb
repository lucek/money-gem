require "dawandamoney/version"

module Dawanda
  class Money
    attr_accessor :amount, :currency

    @convertion_rates = {}

    def initialize(amount, currency)
      raise IncorrectAmountFormatError unless amount.is_a?(Numeric)
      raise IncorrectCurrencyFormatError unless currency.is_a?(String)

      @amount = amount
      @currency = currency
    end

    def self.convertion_rates(currency_code, convertion_rates)
      raise ConversionRatesIsNotAHashError unless convertion_rates.is_a?(Hash)
      raise ConversionRatesAreNotNumbersError unless convertion_rates.map { |k,v| v }.all? { |i| i.is_a?(Numeric) }

      @convertion_rates[currency_code.to_sym] = convertion_rates
    end
  end
end

class IncorrectAmountFormatError < StandardError
end

class IncorrectCurrencyFormatError < StandardError
end

class ConversionRatesIsNotAHashError < StandardError
end

class ConversionRatesAreNotNumbersError < StandardError
end
