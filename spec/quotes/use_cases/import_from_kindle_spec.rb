require 'spec_helper'

class ImportFromKindleSpec < UseCaseSpec
  let(:file) do
    File.read("spec/support/kindle_clippings_with_dups.txt")
  end
  let(:user_uid) { 23 }
  let(:input) do
    {
      :user_uid => user_uid,
      :file => file
    }
  end
  let(:use_case) { Quotes::UseCases::ImportFromKindle.new(input) }
  let(:result) { use_case.call }

  describe "call" do
    describe 'with input that cannot be parsed' do
      let(:file) { "some nonsense" }

      it 'nothing is added to the gateway' do
        assert_equal "Not a valid kindle clippings file", result.error
        assert_empty result.added_quotes
      end
    end

    describe "with parsable input" do
      it "adds all quote entities to the gateway" do
        assert_nil result.error
        quotes = result.added_quotes

        assert_equal 3, quotes.size
        assert_kind_of Quotes::Entities::Quote, quotes.last
        assert_equal 23, quotes.last.added_by
        assert_equal 'Sample Author', quotes.last.author
        assert_includes quotes.last.content, 'sample highlight'
      end

      describe 'with duplicate quotes' do
        before do
          seed_database_with_duplicate_quotes
        end

        it "returns possible duplicates" do
          assert_nil result.error

          duplicates = result.possible_duplicates
          assert_equal 4, duplicates.size
          assert_includes duplicates.flatten.map(&:content),
            "This is a duplicate sample highlight."

          assert_empty result.added_quotes
        end
      end

      def seed_database_with_duplicate_quotes
        input = {
          :user_uid => user_uid,
          :file => File.read("spec/support/sample_kindle_clippings.txt")
        }

        Quotes::UseCases::ImportFromKindle.new(input).call
      end
    end
  end
end
