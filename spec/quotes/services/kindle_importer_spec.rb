require 'spec_helper'

class KindleImporterSpec < ServiceSpec
  let(:user_uid) { 23 }
  let(:autotagger) { FakeAutotagService }
  let(:input) { File.read("spec/support/sample_kindle_clippings.txt") }
  let(:kindle_importer) do
    Quotes::Services::KindleImporter.new(user_uid, input, autotagger)
  end

  let(:result) { kindle_importer.import }

  describe 'import' do

    describe 'without valid input' do
      let(:input)   { '' }

      it 'fails' do
        assert_failure {result}
      end
    end

    describe 'with valid input' do
      let(:first_result)  { result[0] }

      it 'parses the file into quotes and autotags them' do
        assert_kind_of Quotes::Entities::Quote, first_result
        assert_equal 'Ernest Becker', first_result.author
        assert_equal 'The Denial of Death', first_result.title
        assert_includes first_result.tags, 'autotagged'
      end

      it 'returns an array of objects' do
        assert_kind_of Array, result
      end

      it 'only parses notes and highlights' do
        assert_equal 3, result.size
      end

      describe 'used publications' do
        describe 'with existing publications' do
          before do
            create_publication :author => 'Ernest Becker',
              :title => 'The Denial of Death',
              :publisher => 'Previously added publisher'
          end

          it 'uses existing publications if author and title match' do
            assert_equal 'Ernest Becker', result.first.author
            assert_equal 'The Denial of Death', result.first.title
            assert_equal 'Previously added publisher', result.first.publisher
          end
        end

        describe 'with no existing publications' do
          it 'creates a new publication' do
            assert_equal 'Ernest Becker', result.first.author
            assert_equal 'The Denial of Death', result.first.title
            assert_equal 'kindle import', result.first.publisher
          end
        end
      end
    end
  end

  class FakeAutotagService
    def initialize(quote)
      @quote = quote
    end

    def run
      @quote.tags = ['autotagged']
      @quote
    end
  end
end
