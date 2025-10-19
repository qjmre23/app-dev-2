@echo off
echo ==================================
echo Smart Toy Store Backend Server
echo ==================================
echo.

echo Checking Dart installation...
where dart >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Dart is not installed!
    echo Please install Dart SDK from https://dart.dev/get-dart
    pause
    exit /b 1
)

dart --version
echo.

echo Installing dependencies...
call dart pub get

echo.
echo Starting server...
echo Server will be available at:
echo   HTTP API: http://10.40.190.130:8080
echo   WebSocket: ws://10.40.190.130:8080/ws
echo.
echo Press Ctrl+C to stop the server
echo.

dart run bin/server.dart
