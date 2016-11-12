module Dawanda
  class Money
    module Arithmetics
      [:+, :-].each do |operator|
        define_method(operator) do |other|
          raise OtherIsNotDawandaMoneyError unless other.is_a?(Dawanda::Money)
          other = other.convert_to(currency) if currency != other.currency && other.amount != 0

          return self.class.new(amount.send(operator, other.amount).round(2), currency)
        end
      end

      [:==, :>, :<].each do |operator|
        define_method(operator) do |other|
          raise OtherIsNotDawandaMoneyError unless other.is_a?(Dawanda::Money)

          other = other.convert_to(currency) if currency != other.currency && other.amount != 0
          return amount.send(operator, other.amount)
        end
      end

      def /(number)
        raise IncorrectValueError unless number.is_a?(Numeric) and number != 0

        return self.class.new((amount / number).round(2), currency)
      end

      def *(number)
        raise IncorrectValueError unless number.is_a?(Numeric)

        return self.class.new((amount * number).round(2), currency)
      end
    end
  end
end
