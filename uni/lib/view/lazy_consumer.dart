import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uni/model/providers/startup/profile_provider.dart';
import 'package:uni/model/providers/startup/session_provider.dart';
import 'package:uni/model/providers/state_provider_notifier.dart';

/// Wrapper around Consumer that ensures that the provider is initialized,
/// meaning that it has loaded its data from storage and/or remote.
/// The provider will not reload its data if it has already been loaded before.
/// If the provider depends on the session, it will ensure that SessionProvider
/// and ProfileProvider are initialized before initializing itself.
class LazyConsumer<T extends StateProviderNotifier> extends StatelessWidget {
  const LazyConsumer({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext, T) builder;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final provider = Provider.of<T>(context, listen: false);

        // If the provider fetchers depend on the session, make sure that
        // SessionProvider and ProfileProvider are initialized
        final sessionFuture = provider.dependsOnSession
            ? Provider.of<SessionProvider>(context, listen: false)
                .ensureInitialized(context)
                .then((_) async {
                await Provider.of<ProfileProvider>(context, listen: false)
                    .ensureInitialized(context);
              })
            : Future(() {});

        // Load data stored in the database immediately
        await provider.ensureInitializedFromStorage();

        // Finally, complete provider initialization
        if (context.mounted) {
          await sessionFuture.then((_) async {
            await provider.ensureInitializedFromRemote(context);
          });
        }
      } catch (e) {
        Logger().e('Failed to initialize $T: $e');
      }
    });

    return Consumer<T>(
      builder: (context, provider, _) {
        return builder(context, provider);
      },
    );
  }
}
