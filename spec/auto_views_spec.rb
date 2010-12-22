require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'automatic views' do
  describe 'all view' do
    before do
      @articles = (1..3).map do |i|
        article = Article.new(:title => "Test Article #{i}")
        article.save
        article
      end
      @users = (1..2).map do |i|
        user = User.new(:first_name => 'User', :last_name => i.to_s)
        user.save
        user
      end
    end

    it 'should return all documents of type' do
      all = Article.all
      @articles.each do |article|
        all.should include(article)
      end
    end

    it 'should not return documents of different type' do
      all = Article.all
      @users.each do |user|
        all.should_not include(user)
      end
    end
  end

  describe 'view by property' do
    before do
      @tom_articles = (1..2).map do |i|
        article = Article.new(:title => "Test Article #{i}", :author_username => 'tom')
        article.save
        article
      end
      @harry_articles = (3..4).map do |i|
        article = Article.new(:title => "Test Article #{i}", :author_username => 'harry')
        article.save
        article
      end
    end

    it 'should return all documents whose property matches' do
      tom_articles = Article.by_author_username('tom')
      @tom_articles.each do |tom_article|
        tom_articles.should include(tom_article)
      end
    end

    it 'should not return any documents whose property does not match' do
      tom_articles = Article.by_author_username('tom')
      @harry_articles.each do |harry_article|
        tom_articles.should_not include(harry_article)
      end
    end

    it 'should not define by-property views unless specified' do
      lambda { Article.by_title }.should raise_error(NoMethodError)
    end
  end
end
