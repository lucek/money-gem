require "dawandamoney/errors"

module Dawanda
  class Money
    attr_accessor :amount, :currency

    @conversion_rates = {}

    def initialize(amount, currency)
      raise IncorrectAmountFormatError unless amount.is_a?(Numeric)
      raise IncorrectCurrencyFormatError unless currency.is_a?(String)

      @amount = amount
      @currency = currency
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
      other_currency_conversion_rate = nil

      if self.conversion_rates
        other_currency_conversion_rate = self.conversion_rates[other_currency]
      else
        base_currency_conversion_rates = self.class.get_conversion_rates[other_currency.to_sym]

        return if !base_currency_conversion_rates

        other_currency_conversion_rate = 1/base_currency_conversion_rates[self.currency]
      end

      raise NoConvertionRateDefinedError unless other_currency_conversion_rate

      other_currency_amount = (other_currency_conversion_rate * amount).round(2)

      return self.class.new(other_currency_amount, other_currency)
    end

    def +(other)
      other = other.convert_to(currency) if currency != other.currency

      return self.class.new((amount + other.amount).round(2), currency)
    end

    def -(other)
      other = other.convert_to(currency) if currency != other.currency

      return self.class.new((amount - other.amount).round(2), currency)
    end

    def /(number)
      raise IncorrectValueError unless number.is_a?(Numeric) and number != 0

      return self.class.new((amount / number).round(2), currency)
    end

    def *(number)
      raise IncorrectValueError unless number.is_a?(Numeric)

      return self.class.new((amount * number).round(2), currency)
    end

    def ==(other)
      other = other.convert_to(currency) if currency != other.currency

      return amount == other.amount
    end

    def >(other)
      other = other.convert_to(currency) if currency != other.currency

      return amount > other.amount
    end

    def <(other)
      other = other.convert_to(currency) if currency != other.currency

      return amount < other.amount
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
