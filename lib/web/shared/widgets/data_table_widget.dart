import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool showIndex;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showIndex = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.pageBg),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.surfaceContainerLow;
              }
              return AppColors.surfaceContainerLowest;
            }),
            headingTextStyle: TextStyle(fontFamily: 'Roboto', 
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
              letterSpacing: 0.5,
            ),
            dataTextStyle: TextStyle(fontFamily: 'Roboto', 
              fontSize: 13,
              color: AppColors.onSurface,
            ),
            columnSpacing: 24,
            horizontalMargin: 20,
            dividerThickness: 0,
            columns: [
              if (showIndex)
                DataColumn(
                  label: Text('#',
                      style: TextStyle(fontFamily: 'Roboto', 
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText)),
                ),
              ...columns.map((col) => DataColumn(label: Text(col))),
            ],
            rows: rows.asMap().entries.map((entry) {
              return DataRow(
                cells: [
                  if (showIndex)
                    DataCell(Text('${entry.key + 1}',
                        style: TextStyle(fontFamily: 'Roboto', 
                            fontSize: 12, color: AppColors.mutedText))),
                  ...entry.value.map((cell) => DataCell(cell)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

