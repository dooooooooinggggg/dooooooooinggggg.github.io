all: dev

bundle_install:
	rm Gemfile.lock
	bundle install

bundle_serve:
	bundle exec jekyll serve

dev: bundle_install bundle_serve

prd: bundle_install
	JEKYLL_ENV=production bundle exec jekyll build -d _github_pages
