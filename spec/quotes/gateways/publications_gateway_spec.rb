require 'spec_helper'

class PublicationsGatewaySpec < GatewaySpec
  let(:gateway) { Quotes::Gateways::PublicationsGateway.new }
  let(:publication) { build_publication(nil) }
  let(:updated_publication) do
    options = {
      :author => "Different Author",
      :year => 1999
    }

    build_publication(1, options)
  end
  let(:add_publication) { gateway.add(publication) }

  describe "add" do
    it "ensures the added object is a Publication Entity" do
      assert_failure { gateway.add(99) }
    end

    describe "with an already added publication" do
      let(:publication) { build_publication(:uid => "already_here!") }

      it "fails" do
        assert_failure { gateway.add(publication) }
      end
    end

    it "returns the uid of the inserted publication on success" do
      uid = add_publication

      assert_equal 1, uid
    end

    it "serializes the publication and delegates it to the backend" do
      uid = add_publication
      result = gateway.get(uid)

      assert_equal result.added_by, publication.added_by
      assert_equal result.author, publication.author
      assert_equal result.title, publication.title
      assert_equal result.publisher, publication.publisher
      assert_equal result.year, publication.year
    end
  end

  describe "get" do
    it "returns nil if the backend returns nil" do
      assert_nil gateway.get('not_a_stored_uid')
    end
  end

  describe "update" do
    describe "without a persisted object" do
      it "fails" do
        assert_failure { gateway.update(publication) }
      end
    end

    it "updates any changed attributes" do
      uid = add_publication
      gateway.update(updated_publication)
      result = gateway.get(uid)

      refute_equal publication, result
      assert_equal uid, result.uid
      assert_equal updated_publication.added_by, result.added_by
      assert_equal updated_publication.author, result.author
      assert_equal updated_publication.title, result.title
      assert_equal updated_publication.publisher, result.publisher
      assert_equal updated_publication.year, result.year
    end
  end

  describe "all" do
    let(:publication_two) { build_publication(nil,:author => "different") }
    let(:publication_three) { build_publication(nil,:author => "something else") }
    let(:publications) { [publication, publication_two, publication_three] }

    it "returns an empty array if the backend is empty" do
      assert_empty gateway.all
    end

    it "returns all items in the backend" do
      publications.each {|p| gateway.add(p)}
      result = gateway.all

      assert_equal 3, result.size
      assert_equal "Author", result[0].author
      assert_equal "different", result[1].author
      assert_equal "something else", result[2].author
    end
  end

  describe "delete" do
    describe "without a persisted object" do
      it "fails" do
        assert_failure { gateway.delete(publication.uid) }
      end
    end

    it "removes the publication associated with the given uid" do
      uid = gateway.add(publication)
      gateway.delete(uid)

      assert_nil gateway.get(uid)
    end
  end
end
