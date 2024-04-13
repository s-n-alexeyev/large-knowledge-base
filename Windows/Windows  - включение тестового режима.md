Для успешного выполнения следующих команд необходимо отключить _«Secure Boot»_ в UEFI.

>Включение тестового режима
```powershell
bcdedit.exe -set loadoptions DISABLE_INTEGRITY_CHECKS
bcdedit.exe -set TESTSIGNING ON
bcdedit.exe -set NOINTEGRITYCHECKS ON
```

>Отключение тестового режима
```powershell
bcdedit.exe -set loadoptions ENABLE_INTEGRITY_CHECKS
bcdedit.exe -set TESTSIGNING OFF
bcdedit.exe -set NOINTEGRITYCHECKS OFF
```
