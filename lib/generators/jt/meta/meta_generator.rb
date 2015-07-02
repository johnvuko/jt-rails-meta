module Jt
	class MetaGenerator < Rails::Generators::Base
		source_root File.expand_path("../templates", __FILE__)

		def create_initializer_file
			copy_file "meta.yml", "config/locales/meta.yml"
		end
	end
end