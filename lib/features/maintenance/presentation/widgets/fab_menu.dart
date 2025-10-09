import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:flutter/material.dart';



class FABMenu extends StatelessWidget {
  final bool isMenuOpen;
  final MaintenanceCubit cubit;
  final List<FABAction> actions;

  const FABMenu({super.key, required this.isMenuOpen, required this.cubit, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...actions.map((a) => _buildAnimatedAction(context, a, isMenuOpen)),
          AppSpacers.verticalLarge,
          GestureDetector(
            onTap: cubit.toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              width: 50,
              decoration: const BoxDecoration(color: AppColors.energyBlue, shape: BoxShape.circle),
              child: AnimatedRotation(
                turns: isMenuOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(isMenuOpen ? Icons.close : Icons.add, color: AppColors.neutreBlanc),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAction(BuildContext context, FABAction action, bool isMenuOpen) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      offset: isMenuOpen ? Offset.zero : const Offset(0, 1),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: isMenuOpen ? 1 : 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: action.onTap,
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: AppColors.neutreBlanc,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.black26, blurRadius: 6, offset: Offset(0, 2))],
                ),
                alignment: Alignment.center,
                child: action.icon,
              ),
            ),
            AppSpacers.verticalSmall,
          ],
        ),
      ),
    );
  }
}

class FABAction {
  final Widget icon;
  final VoidCallback onTap;

  const FABAction({required this.icon, required this.onTap});
}
