require 'spec_helper'

class QuotesGatewayBackendSpec < GatewayBackendSpec
  let(:publications_backend) { Persistence::Gateways::PublicationsGatewayBackend.new }
  let(:backend) { Persistence::Gateways::QuotesGatewayBackend.new }
  let(:publication) { build_serialized_publication }
  let(:publication_uid) { publications_backend.insert(publication) }
  let(:other_publication) { build_serialized_publication(:author => "Other") }
  let(:other_publication_uid) { publications_backend.insert(other_publication) }
  let(:quote)   { build_serialized_quote(:publication_uid => publication_uid) }
  let(:quote_with_tags) do
    build_serialized_quote(
      :publication_uid => other_publication_uid,
      :tags => ['a', 'b', 'c']
    )
  end
  let(:persisted_quote_with_tags) do
    build_serialized_quote(
      :uid => 1,
      :publication_uid => other_publication_uid,
      :tags => ['a', 'b', 'c','d']
    )
  end

  describe "insert" do
    it "ensures the added object is a Hash" do
      assert_failure { backend.insert(23) }
    end

    describe "with an already added quote" do
      let(:quote) { build_serialized_quote(:uid => "already_here!") }

      it "fails" do
        assert_failure { backend.insert(quote) }
      end
    end

    it "returns the id of the inserted quote on success" do
      quote_id = backend.insert(quote)

      assert_equal 1, quote_id
    end
  end

  describe "get" do
    it "returns nil if the the quote is not persisted" do
      assert_nil backend.get(23)
    end

    it "stores the serialized data in database" do
      uid = backend.insert(quote_with_tags)
      result = backend.get(uid)

      assert_stored(result)
    end
  end

  describe "update" do
    describe "without a persisted quote" do
      it "fails" do
        assert_failure { backend.update(quote) }
      end
    end

    it "updates any changed attributes" do
      uid = backend.insert(quote_with_tags)
      backend.update(persisted_quote_with_tags)
      result = backend.get(uid)

      refute_equal quote_with_tags, result
      assert_equal persisted_quote_with_tags[:tags], result[:tags]
    end
  end

  describe "all" do
    it "returns an empty array if the backend is empty" do
      assert_empty backend.all
    end

    it "returns all items in the backend" do
      backend.insert(quote)
      backend.insert(quote_with_tags)
      result = backend.all

      assert_equal 2, result.size
      assert_equal quote[:tags], result[0][:tags]
      assert_equal publication[:author], result[0][:author]
      assert_equal quote_with_tags[:tags],  result[1][:tags]
      assert_equal other_publication[:author], result[1][:author]
    end
  end

  describe "delete" do
    it "removes the quote associated with the given id" do
      uid = backend.insert(quote)
      backend.delete(uid)

      assert_nil backend.get(uid)
    end

    it "doesn't remove other quotes" do
      uid = backend.insert(quote)
      second_uid = backend.insert(quote_with_tags)
      backend.delete(uid)

      assert_nil backend.get(uid)
      assert_stored  backend.get(second_uid)
    end
  end

  def assert_stored(actual)
    assert_equal quote_with_tags[:added_by], actual[:added_by]
    assert_equal quote_with_tags[:content], actual[:content]
    assert_equal quote_with_tags[:publication_uid], actual[:publication_uid]
    assert_equal quote_with_tags[:page_number], actual[:page_number]
    assert_equal quote_with_tags[:starred], actual[:starred]
    assert_equal quote_with_tags[:tags], actual[:tags]
    assert_equal quote_with_tags[:links], actual[:links]
    assert_equal other_publication[:publication_added_by], actual[:publication_added_by]
    assert_equal other_publication[:author], actual[:author]
    assert_equal other_publication[:title], actual[:title]
    assert_equal other_publication[:publisher], actual[:publisher]
    assert_equal other_publication[:year], actual[:year]
  end
end
