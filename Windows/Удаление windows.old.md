```powershell
takeown /F "C:\Windows.old" /A /R /D Y
```

```powershell
icacls "C:\Windows.old" /grant *S-1-5-32-544:F /T /C /Q
```

```powershell
RD /S /Q "C:\Windows.old"
```
