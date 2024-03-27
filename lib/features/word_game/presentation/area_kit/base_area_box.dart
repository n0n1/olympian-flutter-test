import '../../../../core/presentation/illustrations/bottom_decoration_gradient.dart';
import '../../../../core/utils/physics.dart';
import '../../../../shared.dart';
import 'area_page_controls.dart';

class BaseAreaBox extends StatelessWidget {
  const BaseAreaBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    /// init notifications
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      $notification.init();
    });
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // TODO: Fixme
        // $areaVm.widthOffset.value = $areaScroller.offset;
        return true;
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: $areaScroller,
              physics:
                  CustomScrollPhysics(itemDimension: $areaVm.wordWidth.value),
              child: child,
            ),
          ),
          const BottomGradient(),
          const AreaPageControls(),
        ],
      ),
    );
  }
}
