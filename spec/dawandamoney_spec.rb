require 'spec_helper'
require 'dawandamoney'

describe Dawanda::Money do
  before :all do
    @base_amount = 50
  end
  
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

  describe "#conversion_rates" do
    context "user has passed correct hash with exchange rates" do
      before :all do
        @currency_code = 'EUR'
        @conversion_rates = {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        }

        Dawanda::Money.conversion_rates(@currency_code, @conversion_rates)
      end

      it "should add correct exchange rate key" do
        expect(Dawanda::Money.instance_variable_get(:@conversion_rates)).to include(@currency_code.to_sym)
      end

      it "should add correct exchange rates for the key" do
        expect(Dawanda::Money.instance_variable_get(:@conversion_rates)[@currency_code.to_sym]).to eql(@conversion_rates)
      end
    end
  end

  context "user has not passed correct hash with exchange rates" do
    context "conversion_rates is not a hash" do
      it "should raise ConversionRatesIsNotAHashError" do
        expect { Dawanda::Money.conversion_rates('EUR', []) }.to raise_error(ConversionRatesIsNotAHashError)
      end
    end

    context "conversion_rates is a hash" do
      context "conversion_rates include non numeric values" do
        it "should raise ConversionRatesAreNotNumbersError" do
          expect { Dawanda::Money.conversion_rates('EUR', {'USD' => 'abc'}) }.to raise_error(ConversionRatesAreNotNumbersError)
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
        @conversion_rates = {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        }

        Dawanda::Money.conversion_rates(@currency_code, @conversion_rates)

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
        @money = Dawanda::Money.new(@base_amount, "EUR")
        @other = Dawanda::Money.new(@base_amount + 25.50, "EUR")
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
        Dawanda::Money.conversion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })

        @money = Dawanda::Money.new(@base_amount, "EUR")
        @other = Dawanda::Money.new(@base_amount + 5.50, "USD")
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
        @money = Dawanda::Money.new(@base_amount, "EUR")
        @other = Dawanda::Money.new(@base_amount - 24.50, "EUR")
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
        Dawanda::Money.conversion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })

        @money = Dawanda::Money.new(@base_amount, "EUR")
        @other = Dawanda::Money.new(@base_amount + 3.50, "USD")
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

  describe "./" do
    before :all do
      @money = Dawanda::Money.new(50, "EUR")
    end

    context "user passed correct number value" do
      before :all do
        @number = 2
      end

      it "should return new Dawanda::Money object" do
        expect(@money / @number).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money / @number).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money / @number).amount).to eq(25)
      end
    end

    context "user passed incorrect number value" do
      context "user passed non-numeric value" do
        before :all do
          @number = 'aaa'
        end

        it "should raise IncorrectValueError" do
          expect { @money / @number }.to raise_error(IncorrectValueError)
        end
      end

      context "user passed zero value" do
        before :all do
          @number = 0
        end

        it "should raise IncorrectValueError" do
          expect { @money / @number }.to raise_error(IncorrectValueError)
        end
      end
    end
  end

  describe ".*" do
    before :all do
      @money = Dawanda::Money.new(50, "EUR")
    end

    context "user passed correct number value" do
      before :all do
        @number = 2
      end

      it "should return new Dawanda::Money object" do
        expect(@money * @number).to be_a(Dawanda::Money)
      end

      it "should return new Dawanda::Money object with correct currency" do
        expect((@money * @number).currency).to eq("EUR")
      end

      it "should return new Dawanda::Money object with correct amount" do
        expect((@money * @number).amount).to eq(100)
      end
    end

    context "user passed incorrect number value" do
      context "user passed non-numeric value" do
        before :all do
          @number = 'aaa'
        end

        it "should raise IncorrectValueError" do
          expect { @money * @number }.to raise_error(IncorrectValueError)
        end
      end
    end
  end

  describe ".==" do
    before :all do
      @money = Dawanda::Money.new(@base_amount, "EUR")
    end

    context "user passed two objects with the same currency" do
      context "other object has equal amount" do
        before :all do
          @other = Dawanda::Money.new(50, "EUR")
        end

        it "should return true" do
          expect(@money == @other).to be(true)
        end
      end

      context "other object does not have equal amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount - 24.50, "EUR")
        end

        it "should return false" do
          expect(@money == @other).to be(false)
        end
      end
    end

    context "user passed other object with different currency" do
      before :all do
        Dawanda::Money.conversion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })
      end

      context "other object has equal amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 5.50, "USD")
        end

        it "should return true" do
          expect(@money == @other).to be(true)
        end
      end

      context "other object does not have equal amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(25.50, "USD")
        end

        it "should return false" do
          expect(@money == @other).to be(false)
        end
      end
    end
  end

  describe ".>" do
    before :all do
      @money = Dawanda::Money.new(@base_amount, "EUR")
    end

    context "user passed two objects with the same currency" do
      context "other object has smaller amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount - 1, "EUR")
        end

        it "should return true" do
          expect(@money > @other).to be(true)
        end
      end

      context "other object does not have smaller amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 1, "EUR")
        end

        it "should return false" do
          expect(@money > @other).to be(false)
        end
      end

      context "other object has equal amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount, "EUR")
        end

        it "should return false" do
          expect(@money > @other).to be(false)
        end
      end
    end

    context "user passed other object with different currency" do
      before :all do
        Dawanda::Money.conversion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })
      end

      context "other object has smaller amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 4.50, "USD")
        end

        it "should return true" do
          expect(@money > @other).to be(true)
        end
      end

      context "other object does not have smaller amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 75.50, "USD")
        end

        it "should return false" do
          expect(@money > @other).to be(false)
        end
      end

      context "other object has equal amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 5.5, "USD")
        end

        it "should return false" do
          expect(@money > @other).to be(false)
        end
      end
    end
  end

  describe ".<" do
    before :all do
      @money = Dawanda::Money.new(@base_amount, "EUR")
    end

    context "user passed two objects with the same currency" do
      context "other object has bigger amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 1, "EUR")
        end

        it "should return true" do
          expect(@money < @other).to be(true)
        end
      end

      context "other object does not have bigger amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount - 1, "EUR")
        end

        it "should return false" do
          expect(@money < @other).to be(false)
        end
      end

      context "other object has equal amount" do
        before :all do
          @other = Dawanda::Money.new(@base_amount, "EUR")
        end

        it "should return false" do
          expect(@money < @other).to be(false)
        end
      end
    end

    context "user passed other object with different currency" do
      before :all do
        Dawanda::Money.conversion_rates("EUR", {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        })
      end

      context "other object has smaller amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 6.50, "USD")
        end

        it "should return true" do
          expect(@money < @other).to be(true)
        end
      end

      context "other object does not have smaller amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount - 24.50, "USD")
        end

        it "should return false" do
          expect(@money < @other).to be(false)
        end
      end

      context "other object has equal amount after convertion" do
        before :all do
          @other = Dawanda::Money.new(@base_amount + 5.5, "USD")
        end

        it "should return false" do
          expect(@money < @other).to be(false)
        end
      end
    end
  end
end
