```
takeown /F "C:\Windows.old" /A /R /D Y
```

```
icacls "C:\Windows.old" /grant *S-1-5-32-544:F /T /C /Q
```

```
RD /S /Q "C:\Windows.old"
```
