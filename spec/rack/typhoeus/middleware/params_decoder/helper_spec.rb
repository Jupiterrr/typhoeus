require 'spec_helper'
require "rack/typhoeus"

describe "Rack::Typhoeus::Middleware::ParamsDecoder::Helper" do

  let(:klass) do
    Class.new do
      include Rack::Typhoeus::Middleware::ParamsDecoder::Helper
    end.new
  end

  describe "#decode" do
    let(:decoded) { klass.decode(params) }
    let(:params) { { :array => {'0' => :a, '1' => :b } } }

    it "decodes" do
      expect(decoded[:array]).to match_array([:a, :b])
    end

    it "doesn't modify" do
      expect(decoded).to_not be(params)
    end
  end

  describe "#decode!" do
    let(:decoded) { klass.decode!(params) }

    context "when hash" do
      context "when encoded" do
        context "when simple" do
          let(:params) { { :array => {'0' => :a, '1' => :b } } }

          it "decodes" do
            expect(decoded[:array]).to match_array([:a, :b])
          end

          it "modifies" do
            expect(decoded).to eq(params)
          end
        end

        context "when nested" do
          let(:params) do
            { :array => { '0' => 0, '1' => { '0' => 'sub0', '1' => 'sub1' } } }
          end

          it "decodes" do
            expect(decoded[:array]).to include(0)
            expect(decoded[:array]).to include(['sub0', 'sub1'])
          end

          it "modifies" do
            expect(decoded).to eq(params)
          end
        end
      end

      context "when not encoded" do
        let(:params) { {:a => :a} }

        it "doesn't modify" do
          expect(decoded).to be(params)
        end
      end
    end

    context "when no hash" do
      let(:params) { "a" }

      it "returns self" do
        expect(decoded).to be(params)
      end
    end
  end

  describe "#encoded?" do
    let(:encoded) { klass.send(:encoded?, params) }

    context "when keys are ascending numbers starting with zero" do
      let(:params) { Hash[12.times.map {|i| [i, (i+65).chr]}] }

      it "returns true" do
        expect(encoded).to be_true
      end
    end

    context "when keys are not ascending numbers starting with zero" do
      let(:params) { {:a => 1} }

      it "returns false" do
        expect(encoded).to be_false
      end
    end
  end

  describe "#convert" do
    let(:converted) { klass.send(:convert, params) }

    context "when encoded" do
      let(:params) { {'0' => :a, '1' => :b} }

      it "returns values" do
        expect(converted).to match_array([:a, :b])
      end
    end

    context "when not encoded" do
      let(:params) { {:a => :a} }

      it "returns unmodified" do
        expect(converted).to be(params)
      end
    end
  end
end