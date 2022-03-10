require 'spec_helper'

class PublicationSpec < Minitest::Spec
  let(:added_by) { 23 }
  let(:author) { 'John Doe' }
  let(:title) { 'A Critique of Something' }
  let(:publisher) { 'Pension Books LTD' }
  let(:year) { 2001 }
  let(:uid) { nil }

  let(:publication) do
    Quotes::Entities::Publication.new(added_by, author, title, publisher, year, uid)
  end

  describe 'construction' do
    it 'can be built with five arguments' do
      assert_correct_storage
    end

    describe 'without' do
      describe 'added_by' do
        let(:added_by) {nil}
        it('fails') {assert_failure{publication}}
      end

      describe 'author' do
        let(:author)  {nil}
        it('fails')   {assert_failure{publication}}
      end

      describe 'title' do
        let(:title)  {nil}
        it('fails')   {assert_failure{publication}}
      end

      describe 'publisher' do
        let(:publisher) {nil}
        it('fails') {assert_failure{publication}}
      end

      describe 'year' do
        let(:year) {nil}
        it('fails')   {assert_failure{publication}}
      end
    end
  end

  describe 'reconstruction' do
    let(:uid) { 23 }

    it 'can be built with a uid' do
      assert_correct_storage
    end
  end

  describe 'updating' do
    let(:publication) { build_publication(:uid => 23) }
    let(:updates_hash) { Hash.new }
    let(:result) { publication.update(updates_hash) }

    it 'does not overwrite old values unless updates exist' do
      assert_equal publication.uid, result.uid
      assert_equal publication.added_by, result.added_by
      assert_equal publication.author, result.author
      assert_equal publication.title, result.title
      assert_equal publication.publisher, result.publisher
      assert_equal publication.year, result.year
    end

    describe 'with updated values' do
      let(:updates_hash) do
        {
          :author => 'new author',
          :year => 2000
        }
      end

      it 'updates all given values' do
        assert_equal publication.uid, result.uid
        assert_equal publication.added_by, result.added_by
        assert_equal 'new author', result.author
        assert_equal publication.title, result.title
        assert_equal publication.publisher, result.publisher
        assert_equal 2000, result.year
      end
    end
  end

  def assert_correct_storage
    assert_equal author, publication.author
    assert_equal title, publication.title
    assert_equal publisher, publication.publisher
    assert_equal year, publication.year
    assert_equal uid, publication.uid
  end
end
