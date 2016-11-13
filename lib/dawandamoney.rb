require "dawandamoney/arithmetics"
require "dawandamoney/errors"

module Dawanda
  class Money
    include Dawanda::Money::Arithmetics

    attr_accessor :amount, :currency

    @conversion_rates = {}

    def initialize(amount, currency)
      raise IncorrectAmountFormatError unless amount.is_a?(Numeric)
      raise IncorrectCurrencyFormatError unless currency.is_a?(String)

      @amount, @currency = amount, currency
    end

    def self.conversion_rates(currency_code, conversion_rates)
      raise ConversionRatesIsNotAHashError unless conversion_rates.is_a?(Hash)
      raise ConversionRatesAreNotNumbersError unless conversion_rates.map { |k,v| v }.all? { |i| i.is_a?(Numeric) }

      @conversion_rates[currency_code.to_sym] = conversion_rates
    end

    def inspect
      return "#{format("%.2f", amount)} #{currency}"
    end

    def convert_to(other_currency)
      if self.conversion_rates
        other_currency_conversion_rate = self.conversion_rates[other_currency]
      else
        base_currency_conversion_rates = self.class.get_conversion_rates[other_currency.to_sym]

        other_currency_conversion_rate = base_currency_conversion_rates ?
          1/base_currency_conversion_rates[self.currency].to_f :
          nil
      end

      raise NoConvertionRateDefinedError unless other_currency_conversion_rate

      other_currency_amount = (other_currency_conversion_rate * amount).round(2)

      return self.class.new(other_currency_amount, other_currency)
    end

    protected

    def conversion_rates
      return self.class.get_conversion_rates[currency.to_sym]
    end

    private

    def self.get_conversion_rates
      @conversion_rates
    end
  end
end
