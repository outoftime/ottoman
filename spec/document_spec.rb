require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'document persistence' do
  before do
    @article = Article.new(:title => 'Test article')
    @article.save
  end

  describe 'in same session' do
    it 'should retain the saved model instance on find' do
      Article.get(@article.id).should equal(@article)
    end

    it 'should retain the same model instance over subsequent loads' do
      Article.get(@article.id).should equal(Article.get(@article.id))
    end

    it 'should delete the record' do
      @article.destroy
      lambda { Article.get(@article.id) }.should raise_error(Ottoman::RecordNotFound)
    end
  end

  describe 'in different sessions' do
    before do
      Ottoman.start_session
    end

    after do
      Ottoman.end_session
    end

    it 'should return a different model instance on find' do
      Article.get(@article.id).should_not equal(@article)
    end

    it 'should retain set properties' do
      Article.get(@article.id).title.should == 'Test article'
    end

    it 'should retain unset properties' do
      Article.get(@article.id).body.should be_nil
    end

    it 'should update an existing record' do
      article = Article.get(@article.id)
      article.body = 'Test body'
      article.save
      Ottoman.session do
        Article.get(@article.id).body.should == 'Test body'
      end
    end

    it 'should delete the record' do
      Article.get(@article.id).destroy
      Ottoman.session do
        lambda { Article.get(@article.id) }.should raise_error(Ottoman::RecordNotFound)
      end
    end
  end
end
