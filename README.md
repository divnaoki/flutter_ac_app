# アクセシブルメディアアプリ

## 概要
画像と動画をカテゴリ別に管理し、アクセシビリティに配慮したメディア管理アプリケーションです。

## 機能仕様

### カテゴリ管理
- カテゴリの作成、編集、削除
- カテゴリには動画用・画像用の種類を設定可能
- カテゴリ名は50文字以内
- 作成日時、更新日時を自動記録

### メディア管理
- 画像の追加、表示、削除
- 動画の追加、表示、削除
- カテゴリ別のメディア一覧表示
- メディア名、ファイルパス、カテゴリIDを管理

### アクセシビリティ機能
- スクリーンリーダー対応
- 高コントラスト対応
- タップターゲットサイズの最適化

## データベース設計

### Categories テーブル
```sql
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME
);
```

### Images テーブル
```sql
CREATE TABLE images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  image_path TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
```

### Videos テーブル
```sql
CREATE TABLE videos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  video_path TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);
```

## UI設計

### ホーム画面
- カテゴリ一覧表示
- カテゴリの種類（画像/動画）をアイコンで表示
- カテゴリ追加ボタン

### カテゴリ追加画面
- カテゴリ名入力フィールド
- メディア種類選択（画像用/動画用）
- バリデーション機能

### カテゴリ詳細画面
- カテゴリ情報表示
- メディア一覧表示
- メディア追加ボタン

### メディア追加画面
- メディア名入力
- ファイル選択機能
- カテゴリ選択（該当する種類のカテゴリのみ表示）

## 技術仕様

### フレームワーク
- Flutter 3.x
- Riverpod (状態管理)
- GoRouter (ルーティング)
- Drift (データベース)

### プラットフォーム対応
- iOS
- Android
- Web
- macOS
- Windows
- Linux

## 開発環境セットアップ

```bash
# 依存関係のインストール
flutter pub get

# アプリケーションの実行
flutter run
```

## Windowsでのビルド・実行手順

1. **Gitのインストール**
   - [Git公式サイト](https://git-scm.com/)からインストールしてください。

2. **Flutterのインストール**
   - [Flutter公式サイト](https://docs.flutter.dev/get-started/install/windows)の手順に従ってインストールしてください。

3. **Visual Studioのインストール**
   - WindowsデスクトップアプリのビルドにはVisual Studio（Community版でOK）が必要です。
   - インストール時に「C++によるデスクトップ開発」ワークロードを追加してください。

4. **リポジトリのクローン**
   ```sh
   git clone <リポジトリのURL>
   cd accesible_media_app
   ```

5. **依存パッケージの取得**
   ```sh
   flutter pub get
   ```

6. **Windows用のビルド準備**
   - 通常は`windows/`ディレクトリが含まれているため追加作業は不要です。
   - もし`windows/`ディレクトリが無い場合は、
     ```sh
     flutter create .
     ```
     を実行してください。

7. **アプリの実行**
   ```sh
   flutter run -d windows
   ```
   または、Visual Studio CodeやAndroid Studioの「Run」ボタンからも実行できます。

8. **トラブルシューティング**
   - エラーが出た場合は、エラーメッセージを確認し、必要に応じてFlutter公式ドキュメントや本READMEの内容を参照してください。

## テスト

```bash
# ユニットテストの実行
flutter test

# ウィジェットテストの実行
flutter test test/widget_test.dart
```
