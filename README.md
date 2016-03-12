# JTRailsMeta

[![Gem Version](https://badge.fury.io/rb/jt-rails-meta.svg)](http://badge.fury.io/rb/jt-rails-meta)

JTRailsMeta help you to manage HTML meta tags like title, description, keywords used in Search Engine Optimization (SEO).

## Installation

JTRailsMeta is distributed as a gem, which is how it should be used in your app.

Include the gem in your Gemfile:

    gem 'jt-rails-meta', '~> 1.0'

Create a `meta.yml` file for the translations:

	rails g jt:meta

## Usage

### Basic usage

Include `JT::Rails::Meta` in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
	include JT::Rails::Meta
	...
end
```

Call `meta_tags` in your layout:

```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8" />
    <%= meta_tags %>
</head>
<body>
</body>
```

You have also access to `meta_title`, `meta_description`, `meta_keywords` methods.

Define your meta in `meta.yml` file:

```yaml
en:
  meta:
    # in general you use either prefx or suffix for the title of your page
    # prefix or suffix are not applied on default title and are both optional
    prefix: "My Website - "
    suffix: " - My Website"

    # default meta used if no meta are found for a page
    default:
      title: My WebSite
      description: My super website is about something magnificent
      keywords: "website, some keywords"

    # Exemple of meta for the controller users and the action new
    # title, full_title, description and keywords are all optional
    users:
      new:
        title: Sign up
        description: Description of sign up page
        keywords: "sign up, registration"

    # Another example for the controller home and the action index
    # full_title is used if exceptionally you don't want to use the prefix or suffix
    # you can use either title or full_title
    home:
      index:
        full_title: Home
        description: Description of homepage

```

### Pass parameters to tags

In your controller:

```ruby
class PostsController < ApplicationController
	def show
		@post = Post.find(params[:id])

		set_meta_title({ title: @post.title })
		set_meta_description({ title: @post.title, author: @post.author })
    add_meta_keywords(@post.tags.map(&:name))
	end
end
```

In your `meta.yml` file:

```yaml
en:
  meta:
    posts:
      show:
        title: "%{title}"
        description: "Post about %{title} by %{author}"
```

### Add more tags

You can add more tags with `add_meta_extra` and `add_meta_link` methods:

```ruby
add_meta_extra 'robots' => 'noindex,nofollow'
add_meta_extra { 
		twitter: {
			site: '@mywebsite',
			domain: 'mywebsite.com',
			title: meta_title,
			description: meta_description,
			image: [
				'http://mywebsite.com/image_1.jpg',
				'http://mywebsite.com/image_2.jpg'
			]
		}
	}

add_meta_link 'author', 'https://github.com/jonathantribouharet'
add_meta_link 'publisher', 'https://github.com/jonathantribouharet'
```

There is some methods already created using `add_meta_link` method:
- `add_meta_link_canonical` which is equivalent to `add_meta_link 'canonical'`
- `add_meta_link_author` which is equivalent to `add_meta_link 'author'`
- `add_meta_link_publisher` which is equivalent to `add_meta_link 'publisher'`
- `add_meta_link_alternate` which is equivalent to `add_meta_link 'alternate'`

## Author

- [Jonathan Tribouharet](https://github.com/jonathantribouharet) ([@johntribouharet](https://twitter.com/johntribouharet))

## License

JTRailsMeta is released under the MIT license. See the LICENSE file for more info.
