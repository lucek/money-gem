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

  describe ".convert_to" do
    context "there are convertion rates defined for given currency" do
      before :all do
        @currency_code = 'EUR'
        @convertion_rates = {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        }

        Dawanda::Money.convertion_rates(@currency_code, @convertion_rates)

        @money = Dawanda::Money.new(50, "EUR")
        @converted_to_usd = @money.convert_to("USD")
      end

      context "there is convertion rate defined for other currency" do
        it "should return new Dawanda::Money object" do
          expect(@converted_to_usd).to be_a(Dawanda::Money)
        end

        it "should return correct currency" do
          expect(@converted_to_usd.currency).to eq("USD")
        end

        it "should return correct amount" do
          expect(@converted_to_usd.amount).to eq(55.5)
        end
      end

      context "there is no convertion rate defined for other currency" do
        it "should raise NoConvertionRateDefinedError" do
          expect { @money.convert_to("GBP") }.to raise_error(NoConvertionRateDefinedError)
        end
      end
    end
  end

  describe ".+" do
    context "user passed two objects with the same currency" do
      before :all do
        @money = Dawanda::Money.new(50, "EUR")
        @other = Dawanda::Money.new(75.50, "EUR")
      end

      it "should return new Dawanda::Money object" do
        expect(@money + @other).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money + @other).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money + @other).amount).to eq(125.50)
      end
    end

    context "user passed other object with different currency" do
      before :all do
        Dawanda::Money.convertion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })

        @money = Dawanda::Money.new(50, "EUR")
        @other = Dawanda::Money.new(55.50, "USD")
      end

      it "should return new Dawanda::Money object" do
        expect(@money + @other).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money + @other).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money + @other).amount).to eq(100)
      end
    end
  end

  describe ".-" do
    context "user passed two objects with the same currency" do
      before :all do
        @money = Dawanda::Money.new(50, "EUR")
        @other = Dawanda::Money.new(25.50, "EUR")
      end

      it "should return new Dawanda::Money object" do
        expect(@money - @other).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money - @other).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money - @other).amount).to eq(24.50)
      end
    end

    context "user passed other object with different currency" do
      before :all do
        Dawanda::Money.convertion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })

        @money = Dawanda::Money.new(50, "EUR")
        @other = Dawanda::Money.new(53.50, "USD")
      end

      it "should return new Dawanda::Money object" do
        expect(@money - @other).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money - @other).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money - @other).amount).to eq(1.80)
      end
    end
  end
end
