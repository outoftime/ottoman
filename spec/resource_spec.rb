require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'embedded resource persistence' do
  before do
    @article = Article.new(:title => 'Test article')
  end

  describe 'with single resource' do
    before do
      @article.publication = @publication = Publication.new(:name => 'Test publication')
      @article.save
      Ottoman.start_session
    end

    after do
      Ottoman.end_session
    end

    it 'should load embedded publication as instance of Publication' do
      Article.get(@article.id).publication.should be_a(Publication)
    end

    it 'should load embedded publication with set property' do
      Article.get(@article.id).publication.name.should == 'Test publication'
    end

    it 'should load embedded publication with unset property nil' do
      Article.get(@article.id).publication.subdomain.should be_nil
    end
  end

  describe 'with single resource unset' do
    before do
      @article.save
      Ottoman.start_session
    end

    after do
      Ottoman.end_session
    end

    it 'should have nil value for embedded resource' do
      Article.get(@article.id).publication.should be_nil
    end
  end

  describe 'with resource collection' do
    before do
      @article.comments = [Comment.new(:text => 'Test Comment 1'), Comment.new(:text => 'Test Comment 2')]
      @article.save
      Ottoman.start_session
    end

    after do
      Ottoman.end_session
    end

    it 'should retrieve collection of embedded resources' do
      Article.get(@article.id).comments.map { |comment| comment.text }.should == ['Test Comment 1', 'Test Comment 2']
    end
  end

  describe 'with empty resource collection' do
    before do
      @article.save
      Ottoman.new_session!
    end
  end
end
