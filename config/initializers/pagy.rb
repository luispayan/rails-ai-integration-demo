require "pagy/extras/bootstrap"

# optional - fix for Bootstrap pagination with Turbo
Pagy::DEFAULT[:link_extra] = 'data-turbo-frame="results"'
Pagy::DEFAULT[:limit] = 12
