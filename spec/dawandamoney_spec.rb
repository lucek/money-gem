require 'spec_helper'
require 'dawandamoney'

describe Dawanda::Money do
  describe "#new" do
    context "user has passed correct values" do
      before :all do
        @money = Dawanda::Money.new(50, 'EUR')
      end

      it "should create object instance with correct amount" do
        expect(@money.amount).to eql(50)
      end

      it "should create object instance with correct currency" do
        expect(@money.currency).to eql('EUR')
      end
    end

    context "user has passed incorrect values" do
      context "user has passed non-numeric amount" do
        it "should raise IncorrectAmountFormatError" do
          expect { Dawanda::Money.new("aa", "EUR") }.to raise_error(IncorrectAmountFormatError)
        end
      end

      context "user has passed non-string currency" do
        it "should raise IncorrectCurrencyFormatError" do
          expect { Dawanda::Money.new(50, 123) }.to raise_error(IncorrectCurrencyFormatError)
        end
      end
    end
  end

  describe "#convertion_rates" do
    context "user has passed correct hash with exchange rates" do
      before :all do
        @currency_code = 'EUR'
        @convertion_rates = {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        }

        Dawanda::Money.convertion_rates(@currency_code, @convertion_rates)
      end

      it "should add correct exchange rate key" do
        expect(Dawanda::Money.instance_variable_get(:@convertion_rates)).to include(@currency_code.to_sym)
      end

      it "should add correct exchange rates for the key" do
        expect(Dawanda::Money.instance_variable_get(:@convertion_rates)[@currency_code.to_sym]).to eql(@convertion_rates)
      end
    end
  end

  context "user has not passed correct hash with exchange rates" do
    context "convertion_rates is not a hash" do
      it "should raise ConversionRatesIsNotAHashError" do
        expect { Dawanda::Money.convertion_rates('EUR', []) }.to raise_error(ConversionRatesIsNotAHashError)
      end
    end

    context "convertion_rates is a hash" do
      context "convertion_rates include non numeric values" do
        it "should raise ConversionRatesAreNotNumbersError" do
          expect { Dawanda::Money.convertion_rates('EUR', {'USD' => 'abc'}) }.to raise_error(ConversionRatesAreNotNumbersError)
        end
      end
    end
  end

  describe ".inspect" do
    it "should return correct format" do
      expect(Dawanda::Money.new(50, "EUR").inspect).to eq("50.00 EUR")
    end
  end
end
