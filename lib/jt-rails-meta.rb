module JT
	module Rails
	end
end

module JT::Rails::Meta
	extend ActiveSupport::Concern

	include ActionView::Helpers::TagHelper

	included do
		before_action :create_meta_hash

		helper_method :meta_tags, :meta_title, :meta_description, :meta_keywords, :meta_title_raw
	end

	# Generate HTML tags title, description, keywords and others meta
	def meta_tags
		output = ""

		output += content_tag 'title', meta_title
		output += "\n"
		output += tag 'meta', name: 'description', content: meta_description
		output += "\n"
		output += tag 'meta', name: 'keywords', content: meta_keywords
		output += "\n"

		for link in @meta[:links]
			output += tag 'link', link[:options]
			output += "\n"
		end

		for extra_params in @meta[:extra]
			output += tag 'meta', name: extra_params[:name], content: extra_params[:content]
			output += "\n"
		end

		output.html_safe
	end

	# Content of meta title
	def meta_title
		@meta[:title] ||= set_meta_title
	end

	# Content of meta description
	def meta_description
		@meta[:description] ||= set_meta_description
	end

	# Content of meta keywords
	def meta_keywords
		@meta[:keywords] ||= set_meta_keywords
	end

	# Content of meta title without suffix or prefix
	def meta_title_raw
		@meta[:title_raw]
	end

	# Generate meta title
	# Use meta.default.title if no meta found for the current controller/action
	# Params:
	# +options+:: options passed to I18n
	def set_meta_title(options = {})
		@meta[:title_raw] = I18n.translate("#{meta_key}.title", options)

		if have_translation?(@meta[:title_raw])
			@meta[:title] = "#{@meta[:prefix]}#{@meta[:title_raw]}#{@meta[:suffix]}"
		else
			@meta[:title] = I18n.translate("#{meta_key}.full_title", options)
			@meta[:title] = I18n.translate('meta.default.title') if !have_translation?(@meta[:title])

			@meta[:title_raw] = @meta[:title]
		end
		
		@meta[:title]
	end

	# Generate meta description
	# Use meta.default.description if no meta found for the current controller/action
	# Params:
	# +options+:: options passed to I18n
	def set_meta_description(options = {})
		@meta[:description] = I18n.translate("#{meta_key}.description", options)
		@meta[:description] = I18n.translate('meta.default.description') if !have_translation?(@meta[:description])
		@meta[:description]
	end

	# Generate meta keywords
	# Use meta.default.keywords if no meta found for the current controller/action
	# Params:
	# +options+:: options passed to I18n
	def set_meta_keywords(options = {})
		keywords = I18n.translate("#{meta_key}.keywords", options)
		if !have_translation?(keywords)
			keywords = I18n.translate('meta.default.keywords')
		end

		if @meta[:keywords].blank?
			@meta[:keywords] = keywords
		else
			@meta[:keywords] << ',' << keywords
		end

		@meta[:keywords]
	end

	# Add custom keywords to the meta keywords, must be call before `set_meta_keywords`
	# Params:
	# +keywords+:: array of keywords added to the default keywords
	def add_meta_keywords(keywords)
		if keywords.is_a?(String)
			@meta[:keywords] = keywords
		elsif keywords.is_a?(Array)
			@meta[:keywords] = keywords.join(',')
		end
		@meta[:keywords]
	end

	# Add meta other than title, description, keywords
	# Params:
	# +extra_params+:: hash containing the meta(s) wanted
	def add_meta_extra(extra_params, previous_key = nil)
		for key, value in extra_params
			current_key = previous_key ? "#{previous_key}:#{key}" : key

			if value.is_a?(String) || value.is_a?(Symbol)
				@meta[:extra] << { name: current_key, content: value.to_s }
			elsif value.is_a?(Hash)
				add_meta_extra(value, current_key)
			elsif value.is_a?(Array)
				for v in value
					@meta[:extra] << { name: current_key, content: v.to_s }
				end
			end
		end
	end

	# Add links to meta, used for add 'canonicalæ or 'publisher' links
	def add_meta_link(rel, href, options = {})
		options.merge!(rel: rel, href: href)
		@meta[:links] << {options: options}
	end

# Helpers

	def add_meta_link_canonical(url)
		add_meta_link 'canonical', url
	end

	def add_meta_link_author(url)
		add_meta_link 'author', url
	end

	def add_meta_link_publisher(url)
		add_meta_link 'publisher', url
	end

	def add_meta_link_alternate(url, lang)
		add_meta_link 'alternate', url, hreflang: lang
	end

private

	def create_meta_hash
		@meta = HashWithIndifferentAccess.new
		
		@meta[:extra] = []
		@meta[:links] = []

		@meta[:prefix] = I18n.translate('meta.prefix')
		@meta[:prefix] = "" if !have_translation?(@meta[:prefix])

		@meta[:suffix] = I18n.translate('meta.suffix')
		@meta[:suffix] = "" if !have_translation?(@meta[:suffix])
	end

	# Key used by I18n for the current controller/action
	def meta_key
		"meta.#{request[:controller].sub('/', '.')}.#{request[:action]}"
	end

	def have_translation?(text)
		!text.start_with?('translation missing')
	end

end