import 'package:flutter/material.dart';
import 'package:ritual/services/constants.dart';

class CustomImagePicker extends StatelessWidget {
  const CustomImagePicker({Key? key, required this.onImageSelected})
      : super(key: key);

  final Function(String) onImageSelected; // Callback function

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: Constants.illustrations.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Send the selected image filename back to the calling function
                      onImageSelected(Constants.illustrations[index]);
                      Navigator.pop(
                          context); // Close the dialog after selecting an image
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        Constants.illustrations[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
