echo "start deploy"
cd ../
hexo clean && hexo g && hexo deploy
cd source
echo "end deploy"
