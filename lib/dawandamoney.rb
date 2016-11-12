require "dawandamoney/version"
require 'pry'

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

    def inspect
      return "#{format("%.2f", amount)} #{currency}"
    end

    def convert_to(other_currency)
      convertion_rates = self.convertion_rates
      raise NoConvertionRatesDefinedError unless convertion_rates

      other_currency_convertion_rate = convertion_rates[other_currency]
      raise NoConvertionRateDefinedError unless other_currency_convertion_rate

      other_currency_amount = (other_currency_convertion_rate * amount).round(2)

      return self.class.new(other_currency_amount, other_currency)
    end

    protected

    def convertion_rates
      return self.class.get_convertion_rates[currency.to_sym]
    end

    private

    def self.get_convertion_rates
      @convertion_rates
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

class NoConvertionRatesDefinedError < StandardError
end

class NoConvertionRateDefinedError < StandardError
end
