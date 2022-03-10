require 'spec_helper'

class AutotagSpec < ServiceSpec
  let(:autotag) { Quotes::Services::Autotag.new(quote, tags) }
  let(:tags) { nil }
  let(:result) { autotag.run }
  let(:sample_tags) do
    [
      'love',
      'death',
      'hope',
      'war',
      'earthworms'
    ]
  end

  describe 'with content which does not include any current tags' do
    let(:quote) { create_quote }

    it 'does not add tags' do
      assert_empty result.tags
    end
  end

  describe 'with content which includes current tags' do
    let(:quote) { create_quote :content => 'all is fair in love and warts' }
    before { create_quotes_with_tags(5, sample_tags) }

    it 'adds whole-string matching tags' do
      assert_equal 1, result.tags.size
      assert_includes result.tags, 'love'
      refute_includes result.tags, 'war'
    end

    describe 'tag injection' do
      let(:tags) { ['fair in love'] }

      it 'adds whole-string matching tags from the collection provided' do
        assert_equal 1, result.tags.size
        assert_includes result.tags, 'fair in love'
      end
    end
  end

  private

  def add_tag_to_quote(quote, tag)
    quotes_gateway.update(
      quote.tap { |q| q.tags << tag }
    )
  end
end
