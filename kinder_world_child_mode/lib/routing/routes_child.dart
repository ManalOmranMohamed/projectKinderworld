import 'package:go_router/go_router.dart';

import 'package:kinder_world/features/child_mode/ai_buddy/ai_buddy_screen.dart';
import 'package:kinder_world/features/child_mode/home/activity_of_the_day_screen.dart';
import 'package:kinder_world/features/child_mode/home/child_home_screen.dart';
import 'package:kinder_world/features/child_mode/learn/learn_screen.dart';
import 'package:kinder_world/features/child_mode/learn/lesson_flow_screen.dart';
import 'package:kinder_world/features/child_mode/learn/subject_screen.dart';
import 'package:kinder_world/features/child_mode/play/play_screen.dart';
import 'package:kinder_world/features/child_mode/profile/child_profile_overview_screen.dart';

import 'route_paths.dart';

List<RouteBase> buildChildRoutes() {
  return [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ChildHomeScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.childHome,
              builder: (context, state) => const ChildHomeContent(),
              routes: [
                GoRoute(
                  path: 'activity-of-day',
                  builder: (context, state) => const ActivityOfTheDayScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.childLearn,
              builder: (context, state) => const LearnScreen(),
              routes: [
                GoRoute(
                  path: 'subject/:subject',
                  builder: (context, state) {
                    final subject = state.pathParameters['subject']!;
                    return SubjectScreen(subject: subject);
                  },
                ),
                GoRoute(
                  path: 'lesson/:lessonId',
                  builder: (context, state) {
                    final lessonId = state.pathParameters['lessonId']!;
                    return LessonFlowScreen(lessonId: lessonId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.childPlay,
              builder: (context, state) => const PlayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.childAiBuddy,
              builder: (context, state) => const AiBuddyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.childProfile,
              builder: (context, state) => const ChildProfileOverviewScreen(),
            ),
          ],
        ),
      ],
    ),
  ];
}
