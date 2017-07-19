# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

ignore /(.*)\.ts/
# ignore /(.*)\.js/

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

compass_config do |config|
  config.add_import_path "bower_components/foundation-sites/scss/"
  config.output_style = :compact

  # Set this to the root of your project when deployed:
  config.http_path = "/"
  config.css_dir = "stylesheets"
  config.sass_dir = "stylesheets"
  config.images_dir = "images"
  config.javascripts_dir = "javascripts"
end

activate :sprockets
# Add bower's directory to sprockets asset path
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

# Reload the browser automatically whenever files change
configure :development do
  #activate :livereload
end


set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :partials_dir, 'partials'

activate :directory_indexes

set :index_file, "index.html"




PrismicApi = Prismic.api('https://cadorna10.cdn.prismic.io/api')

gallery = PrismicApi.form('everything')
                .query(Prismic::Predicates.at('document.tags', ['gallery_appartamenti']))
                .orderings('[my.immagini.ordine]')
                .submit(PrismicApi.master_ref)

# Pass that data to the page
page "/index.html", locals: { results: gallery }

helpers do
    def set_prismic_helper_settings(prismic_document_type, results)
      @page = prismic_document_type
      @result = results
    end

    def getImagesAsHash (attr_name)
      imagesHash = {};
      @result.each_with_index do |gallery, indexGallery|

        images = gallery["#{@page}.#{attr_name}"]



        if (images && images.size > 0)
            images.each_with_index do |image, index|

                urlWide = image['picture'].get_view('main').url;
                caption = image["caption"] == nil ? nil : image["caption"].as_text
                link = image["url"] == nil ? nil : image["url"].as_text

                imagesHash ["#{indexGallery}_#{index}"] = {'url' => urlWide , 'caption' => caption, 'link' => link}
            end
        end
      end

      # puts (imagesHash.inspect);

      return imagesHash

    end

    def getImgxUrl (url)

      client = Imgix::Client.new(host: 'cadorna10.imgix.net', secure_url_token: 'hyEywDaqjdKyk7bz')

      return client.path(url).to_url()

    end
end
# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

configure :build do
  activate :minify_css
  # activate :minify_javascript
  activate :gzip
  activate :minify_html, :remove_input_attributes => false
end
