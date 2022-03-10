require 'spec_helper'

class GetPublicationsSpec < UseCaseSpec
  let(:use_case)  { Quotes::UseCases::GetPublications.new }

  describe "call" do
    let(:result) { use_case.call }
    let(:first_result) { result.publications.first }

    describe "with no publications in the db" do
      let(:publications) { nil }

      it "returns an empty array" do
        assert_empty  result.publications
      end
    end

    describe "with 5 publications in the db" do
      before do
        5.times { |i| create_publication_with_title(i) }
      end

      it "retrieves all publications from the backend sorted by title" do
        assert_equal 5, result.publications.size
        assert_kind_of Quotes::Services::PublicationBoundary::Publication, first_result

        assert_equal 5, first_result.uid
        assert_equal 23, first_result.added_by
        assert_equal 'Annotated Works of Shakespeare', first_result.title

        assert_equal 4, result.publications[1].uid
        assert_equal 'Pickling: A Primer', result.publications[1].title

        assert_equal 1, result.publications.last.uid
        assert_equal 'World War II', result.publications.last.title
      end
    end
  end

  def create_publication_with_title(index)
    create_publication(:title => titles[index])
  end

  def titles
    {
      0 => 'World War II',
      1 => 'Dogs',
      2 => 'Anna Karenina',
      3 => 'Pickling: A Primer',
      4 => 'Annotated Works of Shakespeare'
    }
  end
end
