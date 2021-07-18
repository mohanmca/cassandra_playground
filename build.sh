npm run docs
pandoc -s _README.md --toc -o README.md
git add README.md
