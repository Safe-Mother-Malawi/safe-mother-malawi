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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
        child: isMobile
            ? _buildCardView()
            : _buildTableView(),
      ),
    );
  }

  // Card view for mobile
  Widget _buildCardView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final row = rows[index];
        return Container(
          padding: const EdgeInsets.all(16),
          color: index.isEven 
              ? AppColors.surfaceContainerLowest 
              : AppColors.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showIndex)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ...List.generate(
                columns.length,
                (colIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          columns[colIndex],
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: row[colIndex],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Table view for tablet/desktop
  Widget _buildTableView() {
    return SingleChildScrollView(
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
    );
  }
}

