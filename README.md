# Braque

Braque aims to provide a simple and familiar interface for setting up clients to interact with [Hypermedia (hal+json)](http://stateless.co/hal_specification.html) API services. It is a lightweight wrapper around [Hyperclient](https://github.com/codegram/hyperclient) and [ActiveAttr](https://github.com/cgriego/active_attr).

Braque is an early-stage and exploratory project. That said, at [Artsy](https://www.artsy.net), we've used Braque to quickly consume [Gris](https://github.com/artsy/gris) Hypermedia APIs with great benefit.

[![Build Status](https://semaphoreci.com/api/v1/projects/c557a59e-1c1a-4719-a41a-6462a424ddfa/381676/badge.png)](https://semaphoreci.com/dylanfareed/braque)

### Basic model setup

```Braque::Model``` is an ActiveSupport concern. You can use Braque::Model to map a remote resource to a class in your application. Do so by including Braque::Model in the class, defining the API service's root url (required), and listing attributes which we expect to receive from the API.

```ruby
class Article
  include Braque::Model
  api_root_url Rails.application.config_for(:articles_service)['url']

  attribute :id
  attribute :title
  attribute :body
  attribute :summary
  attribute :created_at
  attribute :updated_at
end
```

Braque::Model adds familiar "Active Record"-like `create`, `find`, and `list` class methods to the embedding class (`Article` in the example above) as well as `save` and `destroy` instance methods. These methods wrap Hyperclient to make calls to a remote hypermedia API.

### Usage

In a Rails app, once you've set up your model, you can use the following familiar syntax to query the remote API:

```ruby
class ArticlesController < ApplicationController
  before_filter :find_article, except: [:index, :new]

  def index
    @articles = Article.list(page: params[:page], size: params[:size])
  end

  def new
  end

  def create
    @article = Article.create params[:article]
    redirect_to article_path(@article)
  end

  def show
  end

  def edit
  end

  def update
    @article = @article.save params[:article]
    redirect_to article_path(@article.id)
  end

  def destroy
    @article.destroy
    redirect_to articles_path
  end

  private

  def find_article
    @article = Article.find(id: params[:id])
  end
end

```

### Relations

If your remote API includes associated resources in the `_links` node for a given resource, you can use Braque's relations helpers to make navigating to those associated resources somewhat simpler.

For example if the remote API returns a response for the Book resource like this:

```
{
  "id":1,
  "title":"My Magazine",
  "_links":{
    "self":{
      "href":"http://localhost:9292/magazines/1"
    },
    "articles":{
      "href":"http://localhost:9292/articles?magazine_id=1{&page,size}",
      "templated":true
    }
  }
}
```

And the remote API returns something like the following for a give Article resource:

```
{
  "id":1,
  "title":"My Article",
  "magazine_id": 1,
  "content":"Lorem ipsum...",
  "_links":{
    "self":{
      "href":"http://localhost:9292/articles/1"
    },
    "magazine":{
      "href":"http://localhost:9292/magazines/1"
    }
  }
}
```

In this situation you could choose to setup your Magazine and Article models to include `has_many` and `belongs_to` association helpers.

```ruby
class Magazine
  include ::Braque::Model
  api_root_url 'http://localhost:9292'
  has_many :articles
  attribute :id
  attribute :title
end

class Article
  include ::Braque::Model
  api_root_url 'http://localhost:9292'
  belongs_to :magazine
  attribute :id
  attribute :content
  attribute :magazine_id
end
```

This will allow you to retrieve associated resources without manually constructing a new link.

So instead of something like

```ruby
magazine = Magazine.find id: article.magazine_id
```

you may use the `belongs_to` helper to retrieve the associated resource more simply with

```ruby
magazine = article.magazine
```

Similarly, the `has_many` helper provides retrieval methods for accessing associated resources.

```ruby
articles = magazine.articles
```

This method supports passing params to the remote API as well.

```ruby
articles = magazine.articles(page: 2, size: 20)
```

### Subclassing

Braque supports inheritance for shared setup across multiple models in your app that make calls to the same remote API.

In the following example, `Article` and `Author` classes will inherit the `api_root_url` and `id`, `created_at`, and `updated_at` attributes from `RemoteModel`.

```ruby
class RemoteModel
  include Braque::Model
  api_root_url Rails.application.config_for(:remote_service)['url']

  attribute :id
  attribute :created_at
  attribute :updated_at
end
```

```ruby
class Article < RemoteModel
  attribute :title
  attribute :body
  attribute :summary
end
```

```ruby
class Author < RemoteModel
  attribute :first_name
  attribute :last_name
end
```

### Custom Headers

Braque also supports passing additional headers along with API requests to your remote provider API service.

* Defining an `accept_header` will replace Hyperclient's default `Accept` header with the value you provide.
* Defining an `authorization_header` with your model will result in this value being sent over in an `Authorization` header with your requests.
* Defining an `http_authorization_header` with your model will result in this value being sent over in an `Http-Authorization` header with your requests.

To wit:

```ruby
class Article
  include Braque::Model
  api_root_url Rails.application.config_for(:articles_service)['url']
  http_authorization_header Rails.application.config_for(:articles_service)['token']
  accept_header Rails.application.config_for(:articles_service)['accept_header']

  attribute :id
  attribute :title
end
```
