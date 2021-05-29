#!/bin/bash
#Распаковка разных архивов. Маска в терминале unpack archive_filename.extention
#Например: unpack file.zip
    if [ "$1" ] ; then
    case "$1" in
      *.tar.bz2)   tar -xjf "$1"   ;;
      *.tar.gz)    tar -xzf "$1"   ;;
      *.tar.xz)    tar -xJf "$1"   ;;
      *.tar.lrz)
 if [[ ! "$( which lrzip )" ]];then echo " Установите lrzip: sudo apt-get install lrzip ";
 else
      		   lrzuntar "$1"
      		   fi
                                   ;;
      *.tar.lzo)
 if [[ ! "$( which lzop )" ]];then echo " Установите lzop: sudo apt-get install lzop ";
 else
      		   lzop -d < "$1" | tar -xvf -
      		   fi
                                   ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.lzma)      unlzma "$1"     ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar -xf "$1"    ;;
      *.tbz2)      tar -xjf "$1"   ;;
      *.tgz)       tar -xzf "$1"   ;;
      *.ZIP|*.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *.xz)        unxz "$1"       ;;
      *.lrz)       lrunzip "$1"    ;;
      *.lzo)       lzop -d "$1"    ;;
      *.cab|*.exe)       cabextract "$1" ;;
      *)           tput setf 4
      echo "Неизвестный тип архива"
                   tput sgr0
;;
    esac
  else
                   tput rev
    echo "Применение: unpack имя_архива"
                   tput sgr0
  fi
  exit  0
