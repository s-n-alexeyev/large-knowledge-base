Открываем реестр Win + R и запускаем команду `regedit`
Переходим по этому пути (вставляем его в строку редактора реестра):

```r
reg ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 0 /f
```

Меняем в параметре «**HiberbootEnabled**» значение на 0 и перезапускаем компьютер.