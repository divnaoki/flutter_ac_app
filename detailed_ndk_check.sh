#!/bin/bash

# 詳細NDKバージョン確認スクリプト
# 使用方法: ./detailed_ndk_check.sh

echo "=== 詳細NDKバージョン確認 ==="
echo ""

# 1. Flutterの設定を確認
echo "1. Flutter設定の確認"
flutter config --list | grep -E "(android-sdk|ndk)" || echo "NDK設定が見つかりません"

echo ""

# 2. Android SDKのNDKバージョンを確認
echo "2. Android SDKのNDKバージョン"
if [ -d "$ANDROID_HOME/ndk" ]; then
    echo "インストール済みのNDKバージョン:"
    ls -la "$ANDROID_HOME/ndk" 2>/dev/null || echo "NDKディレクトリが見つかりません"
else
    echo "ANDROID_HOMEが設定されていません"
fi

echo ""

# 3. プロジェクトの設定を確認
echo "3. プロジェクトのNDK設定"
PROJECT_NDK=$(grep "ndkVersion" android/app/build.gradle.kts | sed 's/.*ndkVersion = "\([^"]*\)".*/\1/')
echo "設定されているNDKバージョン: $PROJECT_NDK"

echo ""

# 4. プラグインの詳細確認
echo "4. プラグインのNDK要件詳細"
echo "以下のプラグインはネイティブコードを含むため、NDKバージョンが重要です:"
echo ""

# プラグインとそのNDK要件
declare -A PLUGIN_NDK_REQUIREMENTS=(
    ["file_picker"]="27.0.12077973"
    ["flutter_tts"]="27.0.12077973"
    ["video_player"]="27.0.12077973"
    ["sqlite3_flutter_libs"]="27.0.12077973"
    ["path_provider"]="27.0.12077973"
)

# pubspec.yamlからプラグインを抽出
PLUGINS=$(grep -E "^  [a-zA-Z_][a-zA-Z0-9_]*:" pubspec.yaml | sed 's/^  \([^:]*\):.*/\1/')

for plugin in $PLUGINS; do
    if [[ -n "${PLUGIN_NDK_REQUIREMENTS[$plugin]}" ]]; then
        required_ndk="${PLUGIN_NDK_REQUIREMENTS[$plugin]}"
        if [[ "$PROJECT_NDK" == "$required_ndk" ]]; then
            echo "✅ $plugin: 要求NDK $required_ndk (一致)"
        else
            echo "❌ $plugin: 要求NDK $required_ndk (不一致 - 現在: $PROJECT_NDK)"
        fi
    fi
done

echo ""

# 5. 推奨設定
echo "5. 推奨設定"
echo "最も高いNDKバージョンを使用することを推奨します:"
echo "android/app/build.gradle.kts:"
echo "    ndkVersion = \"27.0.12077973\""
echo ""
echo "理由: NDKは後方互換性があるため、新しいバージョンを使用しても問題ありません" 