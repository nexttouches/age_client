REM 这是一个利用 ImageMagick 做切片的小脚本
REM 只需把图片拖放到该脚本上即可
REM 例如：拖放 bg.png，将产生 bg_0_0.png, bg_1_0.png ... bg_x_y.png 这样的格式

REM 修改 SIZE 可调整切片的尺寸，默认是 512 像素
SET SIZE=512
convert -verbose %1 -crop %SIZE%x%SIZE% -set filename:tile "%%[fx:page.x/%SIZE%]_%%[fx:page.y/%SIZE%]" +repage +adjoin "%~n1_%%[filename:tile]%~x1"