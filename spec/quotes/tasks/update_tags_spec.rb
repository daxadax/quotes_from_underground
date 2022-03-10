require 'spec_helper'
require 'support/fake_gateway_access'

class UpdateTagsSpec < FakeGatewayAccess
    let(:task) { Quotes::Tasks::UpdateTags.new }

    before do
      seed_db_with_tagged_quotes
    end

    it 'autotags all quotes in the db' do
      assert_equal 5, quotes_gateway.all.size

      added_quote_one = add_quote_with_content(
        "A quote about tag_one and tag_two, which also touches on"\
        " issues related to tag_four and tag_five"
      )
      added_quote_two = add_quote_with_content(
        "A simple quote about tag_three and tag_four"
      )

      assert_empty added_quote_one.tags
      assert_empty added_quote_two.tags

      task.run

      updated_quote_one = quotes_gateway.get(added_quote_one.uid)
      assert_equal 4, updated_quote_one.tags.size
      assert_equal ['tag_one', 'tag_two', 'tag_four', 'tag_five'],
        updated_quote_one.tags

      updated_quote_two = quotes_gateway.get(added_quote_two.uid)
      assert_equal 2, updated_quote_two.tags.size
      assert_equal ['tag_three', 'tag_four'], updated_quote_two.tags
    end

    def add_quote_with_content(content)
      create_quote :content => content
    end

    def seed_db_with_tagged_quotes
      5.times do |i|
        create_quote :tags => [ tags[i] ]
      end
    end

    def tags
      %w[
        tag_one
        tag_two
        tag_three
        tag_four
        tag_five
      ]
    end

end
