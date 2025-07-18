import 'package:drift/drift.dart';
import 'tables/category.dart';
import 'tables/image.dart';
import 'tables/video.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Images, Videos])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  // TODO: マイグレーション戦略を実装
  // @override
  // MigrationStrategy get migration {
  //   return MigrationStrategy(
  //     onUpgrade: (Migrator m, int from, int to) async {
  //       if (from < 2) {
  //         await m.addColumn(categories, categories.mediaType);
  //         await customStatement('UPDATE categories SET media_type = "image"');
  //       }
  //     },
  //   );
  // }
}
