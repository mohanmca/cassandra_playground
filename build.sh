nvm use node
npm run docs
pandoc -s _README.md --toc -o README.md
pandoc -s README.md --pdf-engine prince -o README.pdf
git add README.md
git add main.md
git add C*.md
git add README.pdf
git add build.sh
git commit -m "Update"
git push
