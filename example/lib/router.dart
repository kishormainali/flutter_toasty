import 'package:auto_route/auto_route.dart';
import 'package:example/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: HomeRoute.page, path: '/')];
}
