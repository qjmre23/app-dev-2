#!/bin/bash

echo "=================================="
echo "Smart Toy Store Backend Server"
echo "=================================="
echo ""

echo "Checking Dart installation..."
if ! command -v dart &> /dev/null
then
    echo "Error: Dart is not installed!"
    echo "Please install Dart SDK from https://dart.dev/get-dart"
    exit 1
fi

echo "Dart version: $(dart --version)"
echo ""

echo "Installing dependencies..."
dart pub get

echo ""
echo "Starting server..."
echo "Server will be available at:"
echo "  HTTP API: http://10.40.190.130:8080"
echo "  WebSocket: ws://10.40.190.130:8080/ws"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

dart run bin/server.dart
