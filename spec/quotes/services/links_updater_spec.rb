require 'spec_helper'

class LinksUpdaterSpec < ServiceSpec
  let(:gateway)         { Quotes::Gateways::QuotesGateway.new }
  let(:links_updater)   { Quotes::Services::LinksUpdater.new }
  let(:linked_quote)    { create_quote }
  let(:quote)           { create_quote }

  describe "update" do
    before            { links_updater.update(quote.uid, linked_quote.uid) }
    let(:result_one)  { gateway.get(quote.uid) }
    let(:result_two)  { gateway.get(linked_quote.uid) }

    describe "with no link between the quotes" do
      it "adds a link" do
        assert_includes result_one.links,  linked_quote.uid
        assert_includes result_two.links,  quote.uid
      end
    end

    describe "with a link already present between the quotes" do
      before { links_updater.update(quote.uid, linked_quote.uid) }

      it "removes the link" do
        assert_empty result_one.links
        assert_empty result_two.links
      end
    end
  end
end
