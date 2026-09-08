import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ticketpass/core/theme/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  // on utilise des Container du cout pour savoir l'icone selectionner, nous avons besoin de relier un container dans un index pour le comparer au currentIndex. raison pour laquel on utilise les lists ici

  final maListeIcon = [
    Icons.home_outlined,
    Icons.confirmation_number_outlined,
    Icons.credit_card_outlined,
    Icons.person_outline,
  ];
  AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(38),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 76,
          // modifier l'espacement entre mes differents elements
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: AppColors.navBarBackground,
            border: Border.all(color: AppColors.navBarBorder, width: 1),
            borderRadius: BorderRadius.circular(38),
          ),
          child: Row(
            // definir ici le type d'espacement entre mes icones
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(maListeIcon.length, (index) {
              // boolean pour voir si l'index que l'on construit est celui qui est selectionné
              final isSelected = index == currentIndex;
              // print("mon current index est $currentIndex");
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.navBarSelectedBg
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),

                child: IconButton(
                  onPressed: () => onTap(index),
                  icon: Icon(maListeIcon[index]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
