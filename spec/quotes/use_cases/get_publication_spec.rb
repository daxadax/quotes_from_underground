require 'spec_helper'

class GetPublicationSpec < UseCaseSpec
  let(:publication) { create_publication }
  let(:input) { {:uid => publication.uid} }
  let(:use_case) { Quotes::UseCases::GetPublication.new(input) }

  describe "call" do
    let(:result) { use_case.call }

    describe "with unexpected input" do
      let(:publication) { build_publication }

      it "fails" do
        assert_failure { result }
      end
    end

    it "retrieves the publication with the given uid as a bound object" do
      assert_equal publication.uid, result.publication.uid
      assert_equal publication.added_by, result.publication.added_by
      assert_equal publication.author, result.publication.author
      assert_equal publication.title, result.publication.title
      assert_equal publication.publisher, result.publication.publisher
      assert_equal publication.year, result.publication.year
    end
  end
end
