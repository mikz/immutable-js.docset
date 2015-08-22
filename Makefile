

NAME = immutable-js

all: Contents/Resources

TYPEDOC = node_modules/.bin/typedoc
$(TYPEDOC):
	npm install

immutable.d.ts:
	wget https://raw.githubusercontent.com/facebook/immutable-js/master/dist/$@

doc/index.html: $(TYPEDOC) immutable.d.ts
	$(TYPEDOC) --out doc --includeDeclarations --entryPoint 'Immutable' --target ES6 --hideGenerator --verbose --mode file --theme minimal immutable.d.ts

clean:
	- rm -r doc
	- rm $(NAME).tgz

Contents/Resources: doc/index.html
	ruby generate.rb doc/index.html

EXCLUDES = .* *.rb *.json *.ts *.tgz doc node_modules
dist:
	tar $(addprefix --exclude=,$(EXCLUDES)) -C .. -cvzf $(NAME).tgz $(NAME).docset

