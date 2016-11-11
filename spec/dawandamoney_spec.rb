require 'spec_helper'
require 'dawandamoney'

describe Dawandamoney do
  describe "#convertion_rates" do
    context "user has passed correct hash with exchange rates" do
      before :all do
        @currency_code = 'EUR'
        @convertion_rates = {
          'USD'     => 1.11,
          'Bitcoin' => 0.0047
        }

        Dawandamoney.convertion_rates(@currency_code, @convertion_rates)
      end

      it "should add correct exchange rate key" do
        expect(Dawandamoney.instance_variable_get(:@convertion_rates)).to include(@currency_code.to_sym)
      end

      it "should add correct exchange rates for the key" do

        expect(Dawandamoney.instance_variable_get(:@convertion_rates)[@currency_code.to_sym]).to eql(@convertion_rates)
      end
    end
  end

  context "user has not passed correct hash with exchange rates" do
    context "convertion_rates is not a hash" do
      it "should raise ConversionRatesIsNotAHashError" do
        expect { Dawandamoney.convertion_rates('EUR', []) }.to raise_error(ConversionRatesIsNotAHashError)
      end
    end

    context "convertion_rates is a hash" do
      context "convertion_rates include non numeric values" do
        it "should raise ConversionRatesAreNotNumbersError" do
          expect { Dawandamoney.convertion_rates('EUR', {'USD' => 'abc'}) }.to raise_error(ConversionRatesAreNotNumbersError)
        end
      end
    end
  end
end
