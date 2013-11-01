SET SIZE=512
convert -verbose %1 -crop %SIZE%x%SIZE% -set filename:tile "%%[fx:page.x/%SIZE%]_%%[fx:page.y/%SIZE%]" +repage +adjoin "%~n1_%%[filename:tile]%~x1"