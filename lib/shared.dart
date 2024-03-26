/// Consolidate imports that are common across the app.
// ignore_for_file: directives_ordering

library;

export 'dart:developer' hide Flow;
export 'dart:math' hide log;

///  utils
export 'package:collection/collection.dart';
export 'package:dartz/dartz.dart' hide State;

/// Widgets && Presentations Helpers
// export 'package:extra_alignments/extra_alignments.dart';
// export 'package:flextras/flextras.dart';

/// Flutter Framework
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:gap/gap.dart';
export 'package:get_it/get_it.dart';

/// Routres
// export 'package:go_router/go_router.dart';
// export 'package:provider/provider.dart';

/// Assets
// export 'package:olympian/app/assets.dart';

/// Data && Types

/// Global variable for redability
///
export 'package:olympian/shared_bl.dart';
export 'package:watch_it/watch_it.dart';

/// BL

/// Core App Logic
// export 'package:olympian/logic/app_logic.dart';

/// Core Settings Logic
// export 'package:olympian/logic/settings_logic.dart';

/// Routres Impl
// export 'package:olympian/router/router.dart';
// export 'package:olympian/styles/styles.dart';
// export 'package:olympian/uikit/controls/app_image.dart';
// export 'package:olympian/uikit/controls/buttons.dart';
// export 'package:olympian/uikit/controls/circle_buttons.dart';
// export 'package:olympian/uikit/controls/scroll_decorator.dart';
// export 'package:olympian/uikit/scaffolds/app_scaffold.dart';

/// Styles

/// Helper for Random values
// export 'package:rnd/rnd.dart';

/// Responsive
// export 'package:sized_context/sized_context.dart';

// uikit приложения
export 'core/presentation/uikit.dart';
