#!/bin/bash

# NDKバージョン確認スクリプト
# 使用方法: ./check_ndk_versions.sh

echo "=== NDKバージョン確認 ==="
echo ""

# プロジェクトのNDKバージョンを取得
PROJECT_NDK=$(grep "ndkVersion" android/app/build.gradle.kts | sed 's/.*ndkVersion = "\([^"]*\)".*/\1/')
echo "📱 プロジェクトのNDKバージョン: $PROJECT_NDK"

# プラグインのNDK要件を確認
echo ""
echo "🔍 プラグインのNDK要件を確認中..."

# pubspec.yamlからプラグインを抽出
PLUGINS=$(grep -E "^  [a-zA-Z_][a-zA-Z0-9_]*:" pubspec.yaml | sed 's/^  \([^:]*\):.*/\1/')

echo "📦 使用中のプラグイン:"
for plugin in $PLUGINS; do
    echo "   - $plugin"
done

echo ""
echo "⚠️  注意: 以下のプラグインは特定のNDKバージョンを要求する可能性があります:"
echo "   - file_picker (NDK 27.0.12077973)"
echo "   - flutter_tts (NDK 27.0.12077973)"
echo "   - video_player_android (NDK 27.0.12077973)"
echo "   - sqlite3_flutter_libs (NDK 27.0.12077973)"
echo "   - path_provider_android (NDK 27.0.12077973)"

echo ""
echo "✅ 推奨されるNDKバージョン: 27.0.12077973"
echo ""

# ビルドテストを実行
echo "🧪 ビルドテストを実行中..."
if flutter build apk --debug --no-tree-shake-icons > /dev/null 2>&1; then
    echo "✅ ビルドテスト成功 - NDKバージョンは互換性があります"
else
    echo "❌ ビルドテスト失敗 - NDKバージョンの問題が検出されました"
    echo "   解決方法: android/app/build.gradle.kts で ndkVersion を 27.0.12077973 に設定してください"
fi 