echo "开始部署博客"
cd ../
hexo clean && hexo g && hexo deploy
echo "部署完成"
