import './card.dart';
import 'package:flutter/material.dart';

class SectionBuilder extends StatelessWidget {
  final String title;
  final String category;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic> product) onRentPressed;

  const SectionBuilder({
    super.key,
    required this.title,
    required this.category,
    required this.items,
    required this.onRentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                items.map((item) {
                  return ItemCard(
                    imagePath: item['imagePath'],
                    title: item['title'],
                    price: item['price'],
                    onRentPressed: () => onRentPressed(item),
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
