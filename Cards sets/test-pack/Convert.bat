@echo off
chcp 65001 > nul
setlocal

echo ========================================
echo  Конвертация input.xlsx в CardsReg.json
echo ========================================
echo.

rem EXE лежит в родительской папке относительно этого BAT-файла
set "APP_PATH=%~dp0..\CardsRegExcelConverter.exe"

rem Excel-файл лежит рядом с этим BAT-файлом
set "EXCEL_PATH=%~dp0input.xlsx"

echo Утилита:
echo   %APP_PATH%
echo.

echo Excel-файл:
echo   %EXCEL_PATH%
echo.

if not exist "%APP_PATH%" (
    echo ОШИБКА: не найден CardsRegExcelConverter.exe
    echo Проверь, что exe действительно лежит в родительской папке.
    echo.
    pause
    exit /b 1
)

if not exist "%EXCEL_PATH%" (
    echo ОШИБКА: не найден input.xlsx рядом с BAT-файлом.
    echo Положи Excel-файл в эту же папку и назови его input.xlsx.
    echo.
    pause
    exit /b 1
)

echo Запуск конвертации...
echo.

"%APP_PATH%" -f "%EXCEL_PATH%"

echo.
echo ========================================
echo  Работа завершена
echo ========================================
echo.

pause
endlocal