all: dev

bundle_install:
	rm Gemfile.lock
	bundle install

bundle_serve:
	bundle exec jekyll serve

dev: bundle_install bundle_serve

prd: bundle_install
	mv build/dooooooooinggggg.github.io/.git build/
	JEKYLL_ENV=production bundle exec jekyll build -d build/dooooooooinggggg.github.io
	mv build/.git build/dooooooooinggggg.github.io
